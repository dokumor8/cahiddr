extends Area2D

var velocity = Vector2.RIGHT * 100
var speed = 600
var target = 0
var damage = 1
@onready var sender

# Called when the node enters the scene tree for the first time.
func _ready():
#	velocity = Vector2(100, 0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _physics_process(delta):
# Proper behavior should be to continue flying
	if not is_instance_valid(target) or target.get_parent() == null:
		queue_free()
		return

	look_at(target.global_position)
	var dir = (target.global_position - global_position).normalized()
	global_rotation = dir.angle() + PI / 2.0
	velocity = dir * speed
	position += velocity * delta

	if overlaps_body(target):
		target.hit(damage, sender)
		queue_free()


