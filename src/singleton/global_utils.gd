extends Node


func find_closest(targets:Array, from:Vector2) -> Node2D:
	var shortest_distance := 99999999.00
	var result = null

	for target in targets:
		var distance := from.distance_squared_to(target.get_global_position())
		if distance < shortest_distance:
			shortest_distance = distance
			result = target
	
	return result

func on_send_exp(exp_sender_pos, amount):
	var player_pos = PlayerVariables.hero.global_position
	if player_pos.distance_to(exp_sender_pos) < 800:
		PlayerVariables.hero.receive_exp(amount)
#	pass
