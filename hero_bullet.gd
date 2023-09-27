extends Area2D

var velocity = Vector2.RIGHT * 100
var speed = 600
var target = 0
var damage = 1


# Called when the node enters the scene tree for the first time.
func _ready():
#	velocity = Vector2(100, 0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	look_at(target.global_position)
	var dir = (target.global_position - global_position).normalized()
	global_rotation = dir.angle() + PI / 2.0
	velocity = dir * speed
	position += velocity * delta

	if overlaps_body(target):
		target.hit(damage)
		queue_free()

