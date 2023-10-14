extends CharacterBody2D

@export var speed = 250
var shoot_distance = 300
var stop_distance = 300
@onready var shoot_timer = $Timer
# TODO redo via navigation

signal health_changed(new_health, max_health)
signal end_movement()
signal died()


var target = position
var moving = false
var max_health = 10.0
var health = 10.0
var state = "idle"
var aggro_target
var can_shoot = true

func _ready():
	health = max_health
#	shoot_timer.wait_time = respawn_cooldown


func walk_to(walk_marker):
	target = walk_marker.position
	aggro_target = null
	state = "moving"
#	moving = true


func _physics_process(_delta):
	if state == "idle" and aggro_target != null:
		state = "aggro"

	if state == "moving":
		velocity = position.direction_to(target) * speed
		# look_at(target)
		if position.distance_to(target) > 10:
			move_and_slide()
#			move()
		else:
			state = "idle"
#			moving = false
			end_movement.emit()

	elif state == "aggro":
		if not is_instance_valid(aggro_target):
			state = "idle"
		else:
			velocity = position.direction_to(aggro_target.position) * speed
			if position.distance_to(aggro_target.position) > stop_distance:
				move_and_slide()
			if position.distance_to(aggro_target.position) < shoot_distance:
				shoot(aggro_target)


func set_health(new_health):
	health = new_health
	emit_signal("health_changed", new_health, max_health)

	if health <= 0:
		emit_signal("died")


var HeroBullet = preload("res://src/hero_bullet.tscn")
func shoot(shoot_target):
	if can_shoot:
		state = "shooting"
		var bul = HeroBullet.instantiate()
		get_tree().get_root().add_child(bul)
		bul.global_position = global_position
		bul.look_at(shoot_target.global_position)
		var dir = (shoot_target.global_position - global_position).normalized()
		bul.global_rotation = dir.angle() + PI / 2.0
		bul.velocity = dir * bul.speed
		bul.target = shoot_target
		bul.sender = self

		can_shoot = false
		shoot_timer.start()


func set_attack_target(attack_target):
	aggro_target = attack_target
	state = "aggro"
	pass


var HitEffectHero = preload("res://src/effects/hit_effect_hero.tscn")
func hit(damage, _sender):
	
	var hitEffectHero = HitEffectHero.instantiate()
	get_tree().get_root().add_child(hitEffectHero)
	hitEffectHero.global_position = global_position
	set_health(health - damage)
#	print(health)

#func _process(delta):
#	if Input.is_action_pressed("right_click"):
		


func _on_timer_timeout():
	can_shoot = true
	if state == "shooting":
		state = "idle"
	pass # Replace with function body.


	
