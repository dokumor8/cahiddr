extends Node2D




var Defender = preload("res://src/units/defender.tscn")
func _on_spawn_timer_timeout():

	print("Spawining Defender")
	var defender = Defender.instantiate()
	defender.global_position = $SpawnPoint.global_position
	game_world.add_child(defender)
	print(defender)
