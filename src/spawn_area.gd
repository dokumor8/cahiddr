extends Area2D

var spawn_width = 20
var spawn_height = 40
var rng = RandomNumberGenerator.new()
var Unit = preload("res://src/units/unit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	seed(1)
	
	await get_tree().create_timer(1).timeout
	await spawn_sequence(1, 1)
	await get_tree().create_timer(5).timeout
#	await spawn_sequence(10, 0.1)
	await get_tree().create_timer(15).timeout
#	await spawn_sequence(10, 1)
	await get_tree().create_timer(5).timeout
#	await spawn_sequence(10, 0.5)
	await get_tree().create_timer(1).timeout
#	await spawn_sequence(100, 0.5)


func spawn_sequence(amount, delay):
	spawn_enemy()
	for i in amount - 1:
		await get_tree().create_timer(delay).timeout
		spawn_enemy()
	

func spawn_enemy():
	var unit = Unit.instantiate()

	var game_world = find_parent("GameWorld")
	game_world.add_child(unit)
#		shoot_target.emit(Bullet, rotation, position)
	var x_spawn = rng.randi() % spawn_width
	var y_spawn = rng.randi() % spawn_height

	unit.global_position = global_position + Vector2(x_spawn, y_spawn)
#	var king = game_world.find_child("King")
#	unit.set_aggro_target(king)

func _on_king_died():
	$Timer.stop()
