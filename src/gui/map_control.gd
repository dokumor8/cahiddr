extends Control
class_name Minimap

@export var camera_object: Node2D
@export var zoom = 2
@export var tilemap: TileMap

@onready var background = $MarginContainer/Background
@onready var player_marker = $MarginContainer/Background/PlayerMarker
@onready var mob_marker = $MarginContainer/Background/DangerMarker
@onready var king_marker = $MarginContainer/Background/KingMarker
@onready var camera_marker_rect = $MarginContainer/Background/Rectangle2D
@onready var tile_bg = $MarginContainer/Background/TileMapMarker

@onready var icons = {
	"mob": mob_marker,
	"alert": player_marker,
	"king": king_marker
}

var background_scale
var map_scale
var markers = {}


func _ready():
	await get_tree().process_frame
	map_scale = background.size.x / (tilemap.tile_set.tile_size.x * 134)
	var background_scale_x = background.size.x / (get_viewport_rect().size.x * zoom)
	background_scale = Vector2(map_scale, map_scale)
	
	var camera_rect = get_viewport_rect().size
	
	camera_marker_rect.position = background.size / 2
	camera_marker_rect.queue_redraw()
	var camera_rect_scaled = camera_rect * background_scale
	camera_marker_rect.width = camera_rect_scaled.x
	camera_marker_rect.height = camera_rect_scaled.y
	print(camera_rect)
	print(camera_marker_rect.position)

	var map_objects = get_tree().get_nodes_in_group("minimap_objects")
	for item in map_objects:
		var new_marker = icons[item.minimap_icon].duplicate()
		background.add_child(new_marker)
		new_marker.show()
		markers[item] = new_marker


func _process(delta):
	if !camera_object:
		return
	# player_marker.rotation = player.rotation + PI/2

	for item in markers:
		var obj_pos = (item.position) * background_scale
		if background.get_rect().has_point(obj_pos + background.position):
			markers[item].scale = Vector2(1, 1)
		else:
			markers[item].scale = Vector2(0.75, 0.75)

		obj_pos = obj_pos.clamp(Vector2.ZERO, background.size)
		markers[item].position = obj_pos
		#print(background.get_rect())
		#print(obj_pos)
		#print(background.position)
	camera_marker_rect.position = (camera_object.position) * background_scale
