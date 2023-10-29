extends Node2D

@onready var walk_marker = $GameWorld/WalkMarker
@onready var hero = $GameWorld/Hero
@onready var camera = $GameWorld/Camera2D
@onready var tile_map = $GameWorld/TileMap
@onready var tile_highlighter = $GameWorld/TileHighlighter
@onready var game_world = $GameWorld
@onready var respawn_timer = $GameWorld/HeroReviveTimer

var cursor_state = "move"
var camera_speed = 500
var cursor_mode = "normal"
var hero_in_game = true

const BUILDABLE_TERRAIN = 3
var respawn_cooldown = 2

var building_to_build = "defenders"
var can_build = false

func _ready():
	PlayerVariables.hero_respawn_cooldown = 5
	respawn_timer.wait_time = respawn_cooldown
	$GUICanvasLayer/VBoxContainer/HBoxContainer2/BuildButton.pressed.connect(on_build_button_pressed)
	

func _input(event):
	if event.is_action_pressed("right_click"):

		if cursor_mode == "normal":
			click_game_world()
		elif cursor_mode == "build":
			cancel_build_mode()

	if event.is_action_pressed("left_click"):
		if cursor_mode == "build":
			place_building()
		elif cursor_mode == "normal":
			click_select_unit()

#		elif cursor_mode == "build":
#			pass
			# try building here - refuse or build

var DefenderBuilding = preload("res://src/buildings/defender_building.tscn")
var Defender = preload("res://src/units/defender.tscn")
func place_building():
	if can_build:
		print("placing building")
		var defender_building = DefenderBuilding.instantiate()
		defender_building.global_position = tile_highlighter.global_position
		game_world.add_child(defender_building)
		defender_building.spawn_timer.start()
		defender_building.connect("built_unit", on_built_unit)
		print(defender_building)
		cancel_build_mode()
		# TODO
		# mark tiles as taken


func on_built_unit(unit_type: String, builder):
	var defender = Defender.instantiate()
	defender.global_position = builder.spawn_point.global_position
	print("built")
	game_world.add_child(defender)


func cancel_build_mode():
	cursor_mode = "normal"
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
		print(collider_object)
		print("... is selected")


func click_game_world():
	var space = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collision_mask = 0x00000002
	var max_selected = 1
	var intersect_objects = space.intersect_point(parameters, max_selected)

	if (intersect_objects.is_empty()):
		walk_marker.global_position = get_global_mouse_position()
		walk_marker.show()
		hero.walk_to(walk_marker)
	else:
		var enemy_collider = intersect_objects[0]["collider"]
		hero.set_attack_target(enemy_collider)
		walk_marker.hide()
	

func start_build_mode():
	cursor_mode = "build"
	pass


func check_build_position(_building, tile_coords):
	# var width = building.width
	# var height = building.height
	var width = 3
	var height = 2

	for w in range(0, 3):
		for h in range(0, 2):
			var checking_tile = tile_coords + Vector2i(w, h)
			var tile_data = tile_map.get_cell_source_id(0, checking_tile)
			if tile_data != BUILDABLE_TERRAIN:
				return false
	return true


func _physics_process(delta):
	
	var input_direction = Input.get_vector("left", "right", "up", "down")
	var camera_velocity = input_direction * camera_speed
	camera.translate(delta * camera_velocity)

	if cursor_mode == "build":
		handle_build_cursor_move()


func handle_build_cursor_move():
	var building_size = Vector2(96, 64)
#	var building_height = 64
	var mouse_coords = get_global_mouse_position()
#	mouse_coords.x -= 42
#	mouse_coords.y -= 28
	mouse_coords.x += tile_map.cell_quadrant_size / 2
	mouse_coords.y += tile_map.cell_quadrant_size / 2
	mouse_coords -= building_size / 2
	var tile_coords = tile_map.local_to_map(mouse_coords)

	can_build = check_build_position(building_to_build, tile_coords)

	tile_highlighter.hide()
	if can_build:
		var snapped_local_coords = tile_map.map_to_local(tile_coords)

#		print(snapped_local_coords)
		tile_highlighter.position = snapped_local_coords
		tile_highlighter.position -= Vector2(tile_map.cell_quadrant_size/2, tile_map.cell_quadrant_size/2)
		tile_highlighter.show()


#func _process(delta):
#	if Input.is_action_pressed("right_click"):
#		walk_marker.show()
#		walk_marker.position = get_global_mouse_position()
#
#	if ($Hero.position - walk_marker.position).


func _on_hero_end_movement():
	walk_marker.hide()


func on_build_button_pressed():
	start_build_mode()
	print("build mode")
#func _on_unit_shoot_target(Bullet, direction, location):
#	var spawned_bullet = Bullet.instantiate()
#	add_child(spawned_bullet)
#	spawned_bullet.rotation = direction
#	spawned_bullet.position = location
#	spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)


func _on_hero_revive_timer_timeout():
	hero.set_health(hero.max_health)
	game_world.add_child(hero)
	respawn_timer.wait_time = respawn_cooldown
	$GameWorld/HeroReviveTimer.stop()
	hero_in_game = true



func _on_hero_died():
	game_world.remove_child(hero)
	$GameWorld/HeroReviveTimer.start()
	hero_in_game = false




func _on_king_died():
	get_tree().paused = true
#	pass # Replace with function body.


func spawn_unit(building, spawn_position, type):
	print("spawning unit in world")
	var defender = Defender.instantiate()
	defender.position = spawn_position

	
