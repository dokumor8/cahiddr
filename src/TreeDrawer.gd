@tool
extends Node2D
@export var tilemap: TileMap
@export var tree_texture: Texture2D:
	set = _set_texture


var TreeSprite = preload("res://src/units/tree_sprite.tscn")

# Called when the node enters the scene tree for the first time.
var tile_array = []
var rng
#var tree_texture

func _ready():
	rng = RandomNumberGenerator.new()
	seed(1)
	print("hint")
	#tree_texture = ImageTexture.create_from_image(tree_image)
	#await get_tree().create_timer(0.1, false).timeout
	const tile_shift = Vector2(-16, -16)
	
	const shift_magnitude = 10
	var tiles = tilemap.get_used_cells_by_id(0, 2, Vector2i(1, 13), 0)
	print(tiles)
	for tile in tiles:
		print("ready")
		print(tile)
		var snapped_local_coords = tilemap.map_to_local(tile)
		print(snapped_local_coords)
		snapped_local_coords += Vector2(tilemap.tile_set.tile_size)/2
		print(snapped_local_coords)
		var shift_x = rng.randi_range(-shift_magnitude, shift_magnitude)
		var shift_y = rng.randi_range(-shift_magnitude, shift_magnitude)
		var shift_vector = Vector2(shift_x, shift_y)
		tile_array.append(snapped_local_coords + shift_vector)

		var tree = TreeSprite.instantiate()
		tree.global_position = snapped_local_coords + tile_shift + shift_vector
		add_child(tree)


func _set_texture(value):
	# If the texture variable is modified externally,
	# this callback is called.
	tree_texture = value  # Texture was changed.
	queue_redraw()  # Trigger a redraw of the node.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _draw():
	pass
	#if Engine.is_editor_hint():
#
		##if true:
		#const tile_shift = Vector2(-80, -160)
		#for tile in tile_array:
			##var shift_x = rng.randi_range(-shift_magnitude, shift_magnitude)
			##var shift_y = rng.randi_range(-shift_magnitude, shift_magnitude)
			##var shift_vector = Vector2(shift_x, shift_y)
			##var tile = Vector2(1000, 1000)
			##draw_rect(Rect2(tile.x, tile.y, 32, 32), Color.SKY_BLUE, true)
			#draw_texture(tree_texture, tile + tile_shift)
