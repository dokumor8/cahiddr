extends CharacterBody2D

var selected = false
var target_object = 0
@onready var aggroed = false
var shot_count = 0

var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(60.0, 180.0)

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var aggro_target: CharacterBody2D
@onready var shoot_timer = $ShootTimer
@export var speed = 100
var stop_distance = 100.0
var shoot_distance = 150.0
var can_shoot = true
var health = 10
var state = "idle"


func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	animated_sprite.play()
	
	navigation_agent.path_desired_distance = stop_distance
	navigation_agent.target_desired_distance = stop_distance
#	var root_node = get_tree().get_root()
	movement_target_position = position
	
	# Make sure to not await during _ready.
	call_deferred("actor_setup")


func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)



var Bullet = preload("res://src/hero_bullet.tscn")
func shoot(target):
	if can_shoot:
		var bul = Bullet.instantiate()
		get_tree().get_root().add_child(bul)
		bul.global_position = global_position
		bul.look_at(target.global_position)
		var dir = (target.global_position - global_position).normalized()
		bul.global_rotation = dir.angle() + PI / 2.0
		bul.velocity = dir * bul.speed
		bul.target = target
		bul.sender = self

		can_shoot = false
		shoot_timer.start()


func navigate():
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	navigation_agent.set_velocity(new_velocity)


func _physics_process(_delta):
	if not is_instance_valid(aggro_target):
		# TODO query space around the unit and switch aggro there
		# if no one is close, set state to idle
		state = "idle"
	if state == "aggro":
		if position.distance_to(aggro_target.position) < shoot_distance:
			shoot(aggro_target)
		
		set_movement_target(aggro_target.position)

	navigate()
	

func _on_aggro_area_body_entered(body):
	# change state to aggro
	if body.is_in_group("enemy"):
		set_aggro_target(body)
		state = "aggro"
#		target_object = body
#		aggroed = true


func _on_shoot_timer_timeout():
	can_shoot = true


func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


var HitEffectHero = preload("res://src/effects/hit_effect_hero.tscn")
func hit(damage, sender):
	
	var hitEffectHero = HitEffectHero.instantiate()
	get_tree().get_root().add_child(hitEffectHero)
	hitEffectHero.global_position = global_position
	health -= damage
	if health <= 0:
		queue_free()
	set_aggro_target(sender)


func set_aggro_target(unit):
	aggro_target = unit
	set_movement_target(unit.position)


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
