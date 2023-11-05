extends Node2D
@onready var navigation_region = $NavigationRegion2D
@onready var navigation_map_rid = get_world_2d().navigation_map
@onready var _navigation_region = find_child("NavigationRegion2D")


func _ready():
	NavigationServer2D.map_force_update(navigation_map_rid)

func rebake():
	_navigation_region.bake_navigation_mesh(false)

func get_navigation_map_rid():
	return navigation_map_rid
