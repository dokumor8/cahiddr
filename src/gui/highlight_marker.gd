extends Node2D

@export var color = Color.WHITE:
	set = _set_color

@onready var _selection_marker = $Sprite2D


func _ready():
	_recalculate_marker_parameters()


func _set_color(a_color):
	color = a_color
	_recalculate_marker_parameters()


func _recalculate_marker_parameters():
	if _selection_marker == null:
		return
	_selection_marker.set_self_modulate(color)
