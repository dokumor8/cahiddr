@tool
extends Node2D

@export var color :Color = Color.SKY_BLUE
@export var width :int = 10
@export var height :int = 10
@export var line_width:float = 2.0
@export var fill = false


func _ready():
	line_width = 2.0


func _draw():
	line_width = 2.0
	draw_rect(Rect2(position.x-width/2, position.y-height/2, width, height), color, fill, line_width)

