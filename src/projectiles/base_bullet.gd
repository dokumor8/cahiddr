extends Node2D


var _target = null
var _sender = null
var speed = null
var damage = null
var _target_position = null
const hit_distance = 5

func setup(sender, target, parameters):
	if not is_instance_valid(target):
		queue_free()
		return
	global_position = parameters.global_position
	_target = target
	_sender = sender
	speed = parameters.speed
	damage = parameters.damage
	_target_position = _target.global_position
	

func _ready():
	if not is_instance_valid(_target):
		queue_free()


func update_target_position():
	if is_instance_valid(_target):
		_target_position = _target.get_global_position()


func move_towards_position(target_position, delta):
#	look_at(target_position)
	var remaining_vector = target_position - global_position
	var dir = remaining_vector.normalized()
	var velocity = dir * speed
	global_rotation = dir.angle() + PI / 2.0
	global_position += velocity * delta


func check_hit(target_position):
	var remaining_vector = target_position - global_position
	if is_instance_valid(_target):
		if remaining_vector.length() < hit_distance:
			_target.hit(damage, _sender)
			queue_free()
	elif remaining_vector.length() < hit_distance:
		queue_free()


func _physics_process(delta):
	update_target_position()
	move_towards_position(_target_position, delta)
	check_hit(_target_position)
