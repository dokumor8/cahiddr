extends MarginContainer

@export var texture:Texture2D:
	set(value):
		texture = value
		_apply_settings()

## The progressbar we control
@onready var _texture_progress_bar:TextureProgressBar = %TextureProgressBar

## The label showing the cooldown in seconds
@onready var _label:Label = %Label


# Called when the node enters the scene tree for the first time.
func _ready():
	_apply_settings()


func _apply_settings():
	if _texture_progress_bar != null:
		_texture_progress_bar.texture_under = texture

## Called while cooldown transitions run. Will update the state of the 
## cooldown in the UI elements and disable the button until clear_cooldown
## is called.
func set_cooldown(total:float, current:float):
	_label.visible = true
	_texture_progress_bar.max_value = total
	_texture_progress_bar.value = current
	_label.text = "%.1f" % current
	
	
## Called to clear the cooldown. Will enable the button and clear all cooldown
## indicators.	
func clear_cooldown():
	_label.visible = false
	_texture_progress_bar.value = 0	
	_texture_progress_bar.max_value = 100
