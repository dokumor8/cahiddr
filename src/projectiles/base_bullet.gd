extends Area2D


var _target = null
var _sender = null
var speed = null
var damage = null
const hit_distance = 5

func _init(sender, target, parameters):
	speed = parameters.speed
	damage = parameters.damage
	_sender = sender
	_target = target
	

func _ready():
	if not is_instance_valid(_target):
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func get_target_position():
	if is_instance_valid(_target):
		return _target.global_position
	return 


func move_towards_position(target_position, delta):
#	look_at(target_position)
	var remaining_vector = target_position - global_position
	var dir = remaining_vector.normalized()
	var velocity = dir * speed
	global_rotation = dir.angle() + PI / 2.0
	position += velocity * delta


func check_hit(target_position):
	var remaining_vector = target_position - global_position
	if is_instance_valid(_target):
		if remaining_vector.length() < hit_distance:
			_target.hit(damage, _sender)
			queue_free()
	elif remaining_vector.length() < hit_distance:
		queue_free()


func _physics_process(delta):
	var target_position = get_target_position()
	move_towards_position(target_position, delta)
	check_hit(target_position)
