extends Node2D


signal built_unit
@onready var spawn_point = $SpawnPoint
@onready var rally_point = $RallyPoint
@onready var spawn_timer = $SpawnTimer
var Defender = preload("res://src/units/defender.tscn")

var built_units = 0
var max_units = 5
var width
var height
var unit_name = "Building"
var my_units = []
var can_build = true

func _ready():
	var shape_size = $CollisionShape2D.shape.get_size()
	spawn_timer.wait_time = 10
	width = shape_size.x
	height = shape_size.y
	await get_tree().create_timer(1, false).timeout
	emit_signal("built_unit", "defender", self)
	built_units += 1


func my_init():
	spawn_timer.start()
	connect("built_unit", on_built_unit)


func on_built_unit(unit_type: String, builder):
	var defender = Defender.instantiate()
	defender.builder = builder
	defender.global_position = builder.spawn_point.global_position
	GlobalVar.game_world.add_child(defender)
	builder.add_unit(defender)



#var Defender = preload("res://src/units/defender.tscn")
func _on_spawn_timer_timeout():
	if built_units < max_units:
#		print("Spawining Defender")
		emit_signal("built_unit", "defender", self)
		built_units += 1
#	var defender = Defender.instantiate()
#	defender.global_position = $SpawnPoint.global_position
#	game_world.add_child(defender)
#	print(defender)


func add_unit(unit):
	my_units.push_back(unit)


func unit_died():
	built_units -= 1


func set_rally_point(coords: Vector2):
	$RallyPoint.global_position = coords
	for u in my_units:
		if is_instance_valid(u):
			u.move(coords)

