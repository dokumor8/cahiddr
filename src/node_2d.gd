extends Node2D

@onready var walk_marker = $WalkMarker
@onready var hero = $Hero
@onready var camera = $Camera2D
@onready var tile_map = $TileMap
@onready var tile_highlighter = $TileHighlighter

var cursor_state = "move"
var camera_speed = 500
var cursor_mode = "normal"

const BUILDABLE_TERRAIN = 3

func _input(event):
	if event.is_action_pressed("right_click"):

		if cursor_mode == "normal":
	#		Array[Dictionary]
	#		var parameters
			var space = get_world_2d().direct_space_state
			var parameters = PhysicsPointQueryParameters2D.new()
			parameters.position = get_global_mouse_position()
			parameters.collision_mask = 0x00000002
	#		print(parameters.position)

	#		var physics = PhysicsDirectSpaceState2D.new()
	#		parameters.
			var intersect_objects = space.intersect_point(parameters, 4)
	#		print(intersect_objects)
			if (intersect_objects.is_empty()):
				walk_marker.global_position = get_global_mouse_position()
				walk_marker.show()
				hero.walk_to(walk_marker)
			else:
				var enemy_collider = intersect_objects[0]["collider"]
				hero.set_attack_target(enemy_collider)
				walk_marker.hide()
				# TODO attack
		
		elif cursor_mode == "build":
			cursor_mode = "normal"
			tile_highlighter.hide()

	if event.is_action_pressed("left_click"):
		if cursor_mode == "normal":
			cursor_mode = "build"
			start_build_mode()
		
		elif cursor_mode == "build":
			pass
			# try building here - refuse or build


#var walk_marker = $WalkMarker
#
#func _input(event):
#	if event.is_action_pressed("right_click"):
#		walk_marker.position = get_global_mouse_position()

func start_build_mode():	
	pass


func check_build_position(building, tile_coords):
	# var width = building.width
	# var height = building.height
	var width = 3
	var height = 2

	for w in width:
		for h in height:
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
		var mouse_coords = get_global_mouse_position()
		var tile_coords = tile_map.local_to_map(mouse_coords)
#		tile_coords.x -= tile_coords.x
#		tile_coords.y -= tile_coords.y
		var building = "defenders"
		var can_build = check_build_position(building, tile_coords)

		if can_build:
			var snapped_local_coords = tile_map.map_to_local(tile_coords)
			print(snapped_local_coords)
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


#func _on_unit_shoot_target(Bullet, direction, location):
#	var spawned_bullet = Bullet.instantiate()
#	add_child(spawned_bullet)
#	spawned_bullet.rotation = direction
#	spawned_bullet.position = location
#	spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
