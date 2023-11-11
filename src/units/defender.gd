extends CharacterBody2D

var selected = false
var target_object = 0
@onready var aggroed = false
var shot_count = 0
signal health_changed(new_health, max_health)

var movement_speed: float = 200.0
#var movement_target_position: Vector2 = Vector2(60.0, 180.0)

@onready var _movement_trait = $Movement
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var aggro_target: CharacterBody2D
@onready var shoot_timer = $ShootTimer
@onready var builder
@onready var game_world = find_parent("GameWorld")
@export var speed = 100
var shoot_distance = 200.0
var can_shoot = true
var health = 5
var max_health = 5
var state = "idle"
var unit_name = "defender"
var bullet_speed = 700
var damage = 1


func _ready():
	animated_sprite.play()
	
	_movement_trait.my_ready()
	if !builder or !is_instance_valid(builder):
		move(position)
		pass
	else:
		move(builder.rally_point.global_position)
#		movement_target_position = builder.rally_point.global_position


var Bullet = preload("res://src/hero_bullet.tscn")
func shoot(target):
	if can_shoot:
		var bul = Bullet.instantiate()
		var bullet_parameters = {
			"global_position": global_position,
			"speed": bullet_speed,
			"damage": damage
		}
		bul.setup(self, target, bullet_parameters)
		game_world.add_child(bul)

		can_shoot = false
		await get_tree().create_timer(0.5).timeout
		can_shoot = true
#		shoot_timer.start()


func _physics_process(delta):
	_movement_trait.manual_physics_process(delta)
	if not is_instance_valid(aggro_target):
		# TODO query space around the unit and switch aggro there
		# if no one is close, set state to idle
		state = "idle"
		_movement_trait.move(builder.rally_point.global_position)
	if state == "aggro":
		if position.distance_to(aggro_target.position) < shoot_distance:
			shoot(aggro_target)


func _on_aggro_area_body_entered(body):
	# change state to aggro
	if body.is_in_group("enemy") and state != "aggro":
		set_aggro_target(body)
		state = "aggro"


func _on_shoot_timer_timeout():
	can_shoot = true


func move(movement_target: Vector2):
	print(movement_target)
	_movement_trait.move(movement_target)


var HitEffectHero = preload("res://src/effects/hit_effect_hero.tscn")
func hit(damage, sender):
	
	var hitEffectHero = HitEffectHero.instantiate()
	get_tree().get_root().add_child(hitEffectHero)
	hitEffectHero.global_position = global_position
	
	health -= damage
	if health <= 0:
		queue_free()
		if is_instance_valid(builder):
			builder.unit_died()
	if is_instance_valid(sender) and state != "aggro":
		set_aggro_target(sender)


func set_aggro_target(unit):
	aggro_target = unit
	move(unit.position)


#func _on_navigation_agent_2d_velocity_computed(safe_velocity):
#	velocity = safe_velocity
#	move_and_slide()
