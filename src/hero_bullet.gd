extends Area2D

var velocity = Vector2.RIGHT * 100
var speed = 1100
var target = 0
var target_position = Vector2(0, 0)
var damage = 1
@onready var sender


# Called when the node enters the scene tree for the first time.
func _ready():
#	velocity = Vector2(100, 0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func update_position():
	if is_instance_valid(target):
		target_position = target.global_position


func _physics_process(delta):
	
	update_position()
	look_at(target_position)
#	look_at(target_position.global_position)
	var remaining_vector = target_position - global_position
	var dir = remaining_vector.normalized()
	global_rotation = dir.angle() + PI / 2.0
	velocity = dir * speed
	position += velocity * delta

	if is_instance_valid(target):
		if overlaps_body(target):
			target.hit(damage, sender)
			queue_free()
	elif remaining_vector.length() < 20:
		queue_free()

