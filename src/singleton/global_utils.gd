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
