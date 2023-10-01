extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	seed(1)
	var shift_x = randi() % 20 - 10
	var shift_y = randi() % 20 - 10
	global_translate(Vector2(shift_x, shift_y))
	var rotation_shift = deg_to_rad(randi() % 360)
	rotate(rotation_shift)
	play()
	pass # Replace with function body.


func _on_animation_finished():
	queue_free()
#	pass # Replace with function body.

#
#func _on_timer_timeout():
#	queue_free()
##	pass # Replace with function body.
