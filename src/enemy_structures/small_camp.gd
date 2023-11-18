extends Node2D

var spawn_width = 20
var spawn_height = 40
@export var spawn_area :RectangleShape2D
var rng = RandomNumberGenerator.new()
var Unit = preload("res://src/units/unit.tscn")
var camp_level = 2
@onready var state_chart = $StateChart

# Called when the node enters the scene tree for the first time.
func _ready():
	seed(1)
	


func spawn_wave(amount, delay):
	spawn_enemy()
	for i in amount - 1:
		await get_tree().create_timer(delay, false).timeout
		spawn_enemy()
	

func spawn_enemy():
	var unit = Unit.instantiate()

	var game_world = find_parent("GameWorld")
	game_world.add_child(unit)

	var x_spawn = rng.randi() % spawn_width
	var y_spawn = rng.randi() % spawn_height

	unit.global_position = global_position + Vector2(x_spawn, y_spawn)



func _on_send_wave_state_entered():
	print("spawning unit")
	await spawn_wave(camp_level, 0.1)
	state_chart.send_event("building_finished")


func _on_upgrade_state_entered():
	camp_level += 1
	print("camp level up", camp_level)
	state_chart.send_event("upgrading_finished")


func _on_building_units_state_entered():
	print("started_building")
	state_chart.send_event("building_started")
	pass # Replace with function body.


func _on_upgrading_state_entered():
	print("upgrading_started")
	state_chart.send_event("upgrading_started")
	pass # Replace with function body.
