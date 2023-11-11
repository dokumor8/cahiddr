extends NavigationAgent2D

signal movement_finished

const INITIAL_DISPERSION_FACTOR = 0.1

@export var speed: float = 100.0
var _interim_speed: float = 0.0

@onready var _game_world = find_parent("GameWorld")
@onready var _unit = get_parent()


func my_ready():
	
	print("before timer")
	if !is_instance_valid(_game_world) or _game_world._navigation_region == null:
		print(is_instance_valid(_game_world))
		print(_game_world._navigation_region)
		print("waiting")
		await _game_world.ready
	velocity_computed.connect(_on_velocity_computed)
	navigation_finished.connect(_on_navigation_finished)
	set_navigation_map(_game_world.get_navigation_map_rid())
	_align_unit_position_to_navigation()
#	move(
#		(
#			_unit.global_position
#			+ Vector2(randf(), randf()).normalized() * INITIAL_DISPERSION_FACTOR
#		)
#	)
	print(is_connected("velocity_computed", _on_velocity_computed))


func _physics_process(delta):
	_interim_speed = speed * delta
	var next_path_position: Vector2 = get_next_path_position()
	var current_agent_position: Vector2 = _unit.global_transform.origin
	var new_velocity: Vector2 = (
		(next_path_position - current_agent_position).normalized() * _interim_speed
	)
#	print(is_navigation_finished())
	set_velocity(new_velocity)


func move(movement_target: Vector2):
#	print(movement_target)
	target_position = movement_target


func stop():
	target_position = Vector2.INF


func _align_unit_position_to_navigation():
	await get_tree().process_frame  # wait for navigation to be operational
	_unit.global_transform.origin = (
		NavigationServer2D.map_get_closest_point(
			get_navigation_map(), get_parent().global_transform.origin
		)
	)


func _is_moving_actively():
	return get_next_path_position() != _unit.global_position


#func _rotate_in_direction(direction: Vector2):
#	var rotation_target = _unit.global_transform.origin + direction
#	if (
#		not is_zero_approx(direction.length())
#		and not rotation_target.is_equal_approx(_unit.global_transform.origin)
#	):
#		_unit.global_transform = _unit.global_transform.looking_at(rotation_target)


func _on_velocity_computed(safe_velocity: Vector2):
#	_rotate_in_direction(safe_velocity * Vector2(1, 1))
#	print(safe_velocity)
	_unit.global_transform.origin = _unit.global_transform.origin.move_toward(
		_unit.global_transform.origin + safe_velocity, _interim_speed
	)


func _on_navigation_finished():
	target_position = Vector2.INF
	movement_finished.emit()
