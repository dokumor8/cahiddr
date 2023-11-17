extends Node2D

var rng = RandomNumberGenerator.new()

const translate_shift_x = 40
const translate_shift_y = 40
@onready var label = $Label
var initial_text = ""


func _ready():
	
	var shift_x = rng.randi_range(-translate_shift_x, translate_shift_x)
	var shift_y = rng.randi_range(-translate_shift_y, translate_shift_y)
	translate(Vector2(shift_x, shift_y))
#	var rotation_shift = deg_to_rad(rng.randi_range(-10, 10))
#	rotate(rotation_shift)
	label.text = initial_text
	await get_tree().create_timer(0.3, false).timeout
	queue_free()

func set_text(text):
	initial_text = text

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(Vector2(0, -40*delta))

	pass
#
#
#func _on_timer_timeout():
#	queue_free()
#	label.hide()
#	pass # Replace with function body.
