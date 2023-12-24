@tool
extends Node2D

@export var color :Color = Color.SKY_BLUE
@export var width :int = 10:
	set = set_width
@export var height :int = 10:
	set = set_height
@export var line_width:float = 2.0
@export var fill = false


func _ready():
	line_width = 2.0


func set_width(w):
	width = w
	queue_redraw()


func set_height(h):
	height = h
	queue_redraw()


func _draw():
	draw_rect(Rect2(0-width/2, 0-height/2, width, height), color, fill, line_width)

