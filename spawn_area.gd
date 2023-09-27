extends Area2D

var spawn_width = 200
var spawn_height = 400

# Called when the node enters the scene tree for the first time.
func _ready():
	seed(1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


var Unit = preload("res://unit.tscn")
func _on_timer_timeout():
	var unit = Unit.instantiate()
	get_tree().get_root().add_child(unit)
#		shoot_target.emit(Bullet, rotation, position)
	var x_spawn = randi() % spawn_width
	var y_spawn = randi() % spawn_height

	unit.global_position = global_position #+ Vector2(x_spawn, y_spawn)
#		unit.velocity = 
	pass # Replace with function body.
