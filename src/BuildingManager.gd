extends Node2D

@export var tile_highlighter: Sprite2D
@export var tile_map: TileMap
@export var game_world: Node2D
var building_to_build = "defenders"
var can_build


var DefenderBuilding = preload("res://src/buildings/defender_building.tscn")
var Defender = preload("res://src/units/defender.tscn")
func place_building():
	if can_build:
		var defender_building = DefenderBuilding.instantiate()
		defender_building.global_position = tile_highlighter.global_position
		game_world.add_child(defender_building)
		defender_building.spawn_timer.start()
		defender_building.connect("built_unit", on_built_unit)

		var tile_coords = tile_map.local_to_map(defender_building.global_position)

		var x = tile_coords.x
		var y = tile_coords.y
		for h in range(4):
			for w in range(6):
				var cell_coords = Vector2i(x + w, y + h)
				var tile_data = tile_map.get_cell_tile_data(3, cell_coords)
				#tile_data.set_custom_data("buildable", false)
				var target_source_id = 2
				var target_atlas_coords = Vector2i(1, 4)
				tile_map.set_cell(3, cell_coords, target_source_id, target_atlas_coords)
				tile_map.queue_redraw()
				
		PlayerVariables.money -= PlayerVariables.building_cost
		return true
	return false


func on_built_unit(unit_type: String, builder):
	var defender = Defender.instantiate()
	defender.builder = builder
	defender.global_position = builder.spawn_point.global_position
	game_world.add_child(defender)
	builder.add_unit(defender)


func check_build_position(_building, tile_coords):
	# var width = building.width
	# var height = building.height
	var width = 6
	var height = 4

	for w in range(0, width):
		for h in range(0, height):
			var checking_tile = tile_coords + Vector2i(w, h)
			var tile_data = tile_map.get_cell_tile_data(3, checking_tile)
			if not tile_data:
				return false
			if tile_data and not tile_data.get_custom_data("buildable"):
				return false
	return true


func update_build_cursor():
	var building_size = Vector2(192, 128)
	# TODO pass mouse pos here
	var mouse_coords = get_global_mouse_position()
	mouse_coords.x += tile_map.cell_quadrant_size / 2
	mouse_coords.y += tile_map.cell_quadrant_size / 2
	mouse_coords -= building_size / 2
	var tile_coords = tile_map.local_to_map(mouse_coords)

	can_build = check_build_position(building_to_build, tile_coords)

	tile_highlighter.show()
	if can_build:
		var snapped_local_coords = tile_map.map_to_local(tile_coords)

		tile_highlighter.global_position = snapped_local_coords
		tile_highlighter.global_position -= Vector2(tile_map.cell_quadrant_size/2, 
		tile_map.cell_quadrant_size/2)
		tile_highlighter.modulate = Color("green")
	else:
		tile_highlighter.global_position = mouse_coords
		tile_highlighter.modulate = Color("red")
