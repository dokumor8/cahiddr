extends Area2D

signal selected
signal deselected
signal hp_changed
signal action_changed(new_action)
signal action_updated

const MATERIAL_ALBEDO_TO_REPLACE = Color(0.99, 0.81, 0.48)
const MATERIAL_ALBEDO_TO_REPLACE_EPSILON = 0.05

var hp = null:
	set = _set_hp
var hp_max = null:
	set = _set_hp_max
var attack_damage = null
var attack_interval = null
var attack_range = null
var attack_domains = []
var radius = null:
	set = _ignore,
	get = _get_radius
var movement_speed = null:
	set = _ignore,
	get = _get_movement_speed
var sight_range = null

var player = null
var color = null:
	set = _set_color
var action = null:
	set = _set_action

var _action_locked = false

@onready var _game_world = find_parent("GameWorld")


func _ready():
	if player == null:
		await _game_world.ready


func _ignore(_value):
	pass


func _set_hp(value):
	hp = max(0, value)
	hp_changed.emit()
	if hp == 0:
		_handle_unit_death()


func _set_hp_max(value):
	hp_max = value
	hp_changed.emit()


func _get_radius():
	if find_child("Movement") != null:
		return find_child("Movement").radius
	if find_child("MovementObstacle") != null:
		return find_child("MovementObstacle").radius
	return null


func _get_movement_speed():
	if find_child("Movement") != null:
		return find_child("Movement").speed
	return 0.0


func _set_color(a_color):
	color = a_color
	var material = player.get_color_material()


func _set_action(action_node):
	if not is_inside_tree() or _action_locked:
		if action_node != null:
			action_node.queue_free()
		return
	_action_locked = true
	_teardown_current_action()
	action = action_node
	if action != null:
		var action_copy = action  # bind() performs copy itself, but lets force copy just in case
		action.tree_exited.connect(_on_action_node_tree_exited.bind(action_copy))
		add_child(action_node)
	_action_locked = false
	action_changed.emit(action)


func _teardown_current_action():
	if action != null and action.is_inside_tree():
		action.queue_free()
		remove_child(action)  # triggers _on_action_node_tree_exited immediately


func _handle_unit_death():
	tree_exited.connect(func(): GlobalSignals.unit_died.emit(self))
	queue_free()


func _on_action_node_tree_exited(action_node):
	assert(action_node == action, "unexpected action released")
	action = null
