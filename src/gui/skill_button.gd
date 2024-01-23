@tool
extends MarginContainer

signal pressed()

## The progressbar we control
@onready var _texture_progress_bar:TextureProgressBar = %TextureProgressBar

@onready var _button:Button = %Button

func _ready():
	_texture_progress_bar.max_value = 100

	pass


func update_cooldown(new_value):
	_button.disabled = true
	_texture_progress_bar.value = new_value
	
	
func clear_cooldown():
	_button.disabled = false
	_texture_progress_bar.value = 0

## Signal relay for the inner button.
func _on_button_pressed():
	pressed.emit()
