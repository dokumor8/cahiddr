extends Node2D

@onready var walk_marker = $GameWorld/WalkMarker
@onready var hero = $GameWorld/DeathWarden
@onready var king = %King
#@onready var hero = $GameWorld/Hero
@onready var camera = %Camera2D
@onready var tile_map = %TileMap
@onready var tile_highlighter = $GameWorld/TileHighlighter
@onready var rally_cursor = $GameWorld/RallyPointCursor
@onready var game_world = $GameWorld
@onready var ui = $GUICanvasLayer
@onready var selected_unit = null
@onready var rally_possible_area = $GameWorld/RallyPossibleArea
@onready var rally_rect = $GameWorld/RallyPossibleArea/RallyShape2D
@onready var rally_root = $GameWorld/RallyRoot

var cursor_state = "move"
var camera_speed = 600
#var cursor_mode = "normal"
var hero_in_game = true

# source_id 2, atlas coords (0, 4)
const BUILDABLE_TERRAIN = [2, 0, 4]
const REGULAR_TERRAIN = [2, 1, 4]
var respawn_cooldown = 10

var building_to_build = "defenders"
var can_build = false


func _ready():
	PlayerVariables.hero_respawn_cooldown = 5
	$GUICanvasLayer.build_button.pressed.connect(on_build_button_pressed)
	$GUICanvasLayer.rally_button.pressed.connect(on_rally_button_pressed)
	ui.update_selected_unit(hero)
	hero.movement_finished.connect(_on_hero_movement_finished)
	hero.died.connect(_on_hero_died)
	PlayerVariables.hero = hero
	PlayerVariables.king = king
	
	#$GameWorld/DemonSoldier.init_attack_king()
#	set_buildable_tiles()


func _input(event):

	if event.is_action_pressed("right_click"):
		if GlobalVar.cursor_mode == "normal":
			click_game_world()
		elif GlobalVar.cursor_mode == "build":
			set_cursor_mode_normal()
		elif GlobalVar.cursor_mode == "rally":
			set_cursor_mode_normal()

	if event.is_action_pressed("left_click"):
		if GlobalVar.cursor_mode == "build":
			place_building()
		elif GlobalVar.cursor_mode == "normal":
#			click_select_unit()
			pass
		elif GlobalVar.cursor_mode == "rally":
			set_rally_points()


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
		set_cursor_mode_normal()


func on_built_unit(unit_type: String, builder):
	var defender = Defender.instantiate()
	defender.builder = builder
	defender.global_position = builder.spawn_point.global_position
	game_world.add_child(defender)
	builder.add_unit(defender)


func set_rally_points():
#	var mc = get_global_mouse_position()
	var mc = rally_cursor.global_position
#	var all_buildings = get_tree().get_nodes_in_group("building")
	var selected_units = get_tree().get_nodes_in_group("selected_units")
	if selected_units.is_empty():
		set_cursor_mode_normal()
		return
	var selected_building = selected_units[0]
	if selected_building.is_in_group("building"):
		selected_building.set_rally_point(mc)
	set_cursor_mode_normal()


func set_cursor_mode_normal():
	GlobalVar.cursor_mode = "normal"
	rally_cursor.hide()
	tile_highlighter.hide()


func click_select_unit():
	var space = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collision_mask = 0x00000003
	var max_selected = 1
	var intersect_objects = space.intersect_point(parameters, max_selected)
	if not intersect_objects.is_empty():
		var collider_object = intersect_objects[0]["collider"]
		if selected_unit != null:
			selected_unit.health_changed.disconnect(ui.on_selected_health_changed)
		selected_unit = collider_object
		ui.update_selected_unit(selected_unit)
		selected_unit.health_changed.connect(ui.on_selected_health_changed)


func click_game_world():
	var space = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collision_mask = 0x00000002
	parameters.set_collide_with_areas(true)
	var max_selected = 10
	var intersect_objects = space.intersect_point(parameters, max_selected)

	if (intersect_objects.is_empty()):
		walk_marker.global_position = get_global_mouse_position()
		walk_marker.show()
		hero.walk_to(walk_marker.global_position)
	else:
		var enemy_collider = intersect_objects[0]["collider"]
		hero.attack(enemy_collider)
		walk_marker.hide()
	

func start_build_mode():
	GlobalVar.cursor_mode = "build"
	pass


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


func draw_rally_point_cursor():
	var mouse_coords = get_global_mouse_position()

	var space = get_world_2d().direct_space_state
	var parameters_point = PhysicsPointQueryParameters2D.new()
	parameters_point.collide_with_areas = true
	parameters_point.collide_with_bodies = false
	parameters_point.position = mouse_coords
	parameters_point.collision_mask = 0x00000008
	
	var max_selected = 1
	var intersect_objects = space.intersect_point(parameters_point, 1)
	if intersect_objects:
		rally_cursor.global_position = mouse_coords
	else:
		var space_state = get_world_2d().direct_space_state
		var parameters = PhysicsRayQueryParameters2D.new()
		parameters.collide_with_areas = true
		parameters.collide_with_bodies = false
		parameters.collision_mask = 0x00000008
		parameters.from = mouse_coords
		parameters.to = rally_root.global_position
		
		var ray_result = space_state.intersect_ray(parameters)
		if not ray_result.is_empty():
			rally_cursor.global_position = ray_result["position"]


func _physics_process(delta):
	
	#display/window/size/viewport_height
	#display/window/size/viewport_width
	var window_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	var window_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	#
	#var input_direction = Input.get_vector("left", "right", "up", "down")
	#var camera_velocity = input_direction * camera_speed
	#var camera_target_pos = camera.position + delta * camera_velocity
	#var top_left = Vector2(camera.limit_left + window_width / 2, camera.limit_top + window_height / 2)
	#var bottom_right = Vector2(camera.limit_right - window_width / 2, camera.limit_bottom - window_height / 2)
	#var camera_target_pos2 = camera_target_pos.clamp(top_left, bottom_right)
	#camera.position = camera_target_pos2

	if GlobalVar.cursor_mode == "build":
		handle_build_cursor_move()
	elif GlobalVar.cursor_mode == "rally":
		draw_rally_point_cursor()


func handle_build_cursor_move():
	var building_size = Vector2(192, 128)
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


func _on_hero_movement_finished():
	walk_marker.hide()


func on_build_button_pressed():
	start_build_mode()


func on_rally_button_pressed():
	GlobalVar.cursor_mode = "rally"
	rally_cursor.show()


func _on_hero_died():
	game_world.remove_child(hero)
	hero_in_game = false
	await get_tree().create_timer(respawn_cooldown, false).timeout
	if not is_instance_valid($GameWorld/King):
		return
	hero.set_health(hero.max_health)
	hero.global_position = $GameWorld/King.global_position
	game_world.add_child(hero)
	hero_in_game = true


func _on_king_died():
	ui.restart_button.show()


func spawn_unit(building, spawn_position, type):
	var defender = Defender.instantiate()
	defender.position = spawn_position
