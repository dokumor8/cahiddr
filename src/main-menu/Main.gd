extends Control


func _ready():
	var play_button = find_child("Button")
	play_button.pressed.connect(_on_play_button_pressed)


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://src/node_2d.tscn")
