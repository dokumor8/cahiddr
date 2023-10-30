extends Node2D


signal built_unit
@onready var spawn_point = $SpawnPoint
@onready var spawn_timer = $SpawnTimer

var built_units = 0
var max_units = 5
var width
var height
var unit_name = "Building"
var my_units = []

func _ready():
	var shape_size = $CollisionShape2D.shape.get_size()
	width = shape_size.x
	height = shape_size.y


#var Defender = preload("res://src/units/defender.tscn")
func _on_spawn_timer_timeout():
	print("Spawining Defender")
	emit_signal("built_unit", "defender", self)
#	var defender = Defender.instantiate()
#	defender.global_position = $SpawnPoint.global_position
#	game_world.add_child(defender)
#	print(defender)


func set_rally_point(coords: Vector2):
	$RallyPoint.global_position = coords

