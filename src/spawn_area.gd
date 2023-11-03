extends Area2D

var spawn_width = 200
var spawn_height = 400
var rng = RandomNumberGenerator.new()
var Unit = preload("res://src/units/unit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	seed(1)
	await spawn_sequence(5, 1)
	await get_tree().create_timer(5).timeout
	await spawn_sequence(10, 0.1)
	await get_tree().create_timer(15).timeout
	await spawn_sequence(10, 1)
	await get_tree().create_timer(5).timeout
	await spawn_sequence(10, 0.5)
	await get_tree().create_timer(1).timeout
	await spawn_sequence(100, 0.5)


func spawn_sequence(amount, delay):
	spawn_enemy()
	for i in amount - 1:
		await get_tree().create_timer(delay).timeout
		spawn_enemy()
	

func spawn_enemy():
	var unit = Unit.instantiate()
	get_tree().get_root().add_child(unit)
#		shoot_target.emit(Bullet, rotation, position)
	var x_spawn = rng.randi() % spawn_width
	var y_spawn = rng.randi() % spawn_height

	unit.global_position = global_position + Vector2(x_spawn, y_spawn)
#		unit.velocity = 
	pass # Replace with function body.


func _on_king_died():
	$Timer.stop()
