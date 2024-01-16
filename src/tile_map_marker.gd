extends Node2D

@export var tilemap :TileMap
var tile_image: Image
@onready var tile_texture: ImageTexture

func _ready():
	
	await get_tree().process_frame
	tile_image = Image.create(134, 134, false, Image.FORMAT_RGB8)
	tile_texture = ImageTexture.create_from_image(tile_image)
	update_map()
	#var all_cells = tilemap.get_used_cells(0)
	# # tile_image.lock()
	#for cell in all_cells:
		#var tile_data = tilemap.get_cell_tile_data(0, cell)
		#tile_data
		#tile_data.set_custom_data("color", )
		#if tile_data and not tile_data.get_custom_data("buildable"):
		#tile_image.set_pixel(cell.x, cell.y, Color.DARK_GREEN)

#func _process(delta):
	#
	#await get_tree().create_timer(1, false).timeout

func update_map():
	var all_cells = tilemap.get_used_cells(0)
	#tile_image.lock()
	for cell in all_cells:
		var tile_data = tilemap.get_cell_tile_data(0, cell)
		var color = tile_data.get_custom_data("color")
		tile_image.set_pixel(cell.x, cell.y, color)
	#tile_image.unlock()
	
	tile_texture = ImageTexture.create_from_image(tile_image)
	queue_redraw()


func _draw():
	draw_texture(tile_texture, Vector2())
