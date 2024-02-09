#@tool
extends TileMap
#@export var tree_texture: Texture2D:
	#set = _set_texture
#var TreeSprite = preload("res://src/units/tree_sprite.tscn")

# Called when the node enters the scene tree for the first time.
var tile_array = []
#var tree_texture

func _ready():
	pass
	#tree_texture = ImageTexture.create_from_image(tree_image)
	
	#var tiles = get_used_cells_by_id(-1, 2, Vector2i(1, 13), 0)
	#for tile in tiles:
		#print("ready")
		#print(tile)
		#var snapped_local_coords = map_to_local(tile)
		#print(snapped_local_coords)
		#snapped_local_coords += Vector2(tile_set.tile_size)/2
		#print(snapped_local_coords)
		#tile_array.append(snapped_local_coords)
		##var tree = TreeSprite.instantiate()
		##tree.global_position = snapped_local_coords
		##add_child(tree)
	#await get_tree().create_timer(0.5, false).timeout
	#queue_redraw()

#
#func _set_texture(value):
	## If the texture variable is modified externally,
	## this callback is called.
	#tree_texture = value  # Texture was changed.
	#queue_redraw()  # Trigger a redraw of the node.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#
#func _draw():
	##if true:
	#var tiles: Array[Vector2i] = get_used_cells(3)
	#for tile in tiles:
		#var tile_data = get_cell_tile_data(3, tile)
		#var coords = map_to_local(tile)
		#if tile_data.get_custom_data("buildable"):
			#print(tile)
			#draw_rect(Rect2(coords.x, coords.y, 32, 32), Color.SKY_BLUE, true)
		#
	##for tile in tile_array:
		#var tile = Vector2(1000, 1000)
		#print("drawing")
		#print(tile)
		#print(tree_texture)
		#draw_rect(Rect2(tile.x, tile.y, 32, 32), Color.SKY_BLUE, true)
		#draw_texture(tree_texture, tile)
