extends Area2D

var selected = false
var target_object = 0
@onready var aggroed = false
var shot_count = 0
signal health_changed(new_health, max_health)
signal movement_finished()
var movement_speed: float = 200.0
#var movement_target_position: Vector2 = Vector2(60.0, 180.0)


@onready var _movement_trait = $Movement
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var aggro_target: Area2D
var potential_target: Node2D
#@onready var shoot_timer = $ShootTimer
@onready var state_chart:StateChart = $StateChart
@export var builder: Node2D
@onready var aggro_area = $AggroArea
@onready var game_world = find_parent("GameWorld")
@export var speed = 100
var shoot_distance = 250.0
var can_shoot = true
var health = null
var max_health = 60
var state = "idle"
var unit_name = "defender"
var bullet_speed = 600
var damage = 2
var can_update_chase = true

var regen = 0.5 # per second


func _ready():
	health = max_health
	animated_sprite.play()
	
	_movement_trait.my_ready()
	if !builder or !is_instance_valid(builder):
		move(position)
		pass
	else:
		move(builder.rally_point.global_position)
#		movement_target_position = builder.rally_point.global_position
	_movement_trait.movement_finished.connect(on_movement_finished)
	health_changed.connect($HealthBar._on_health_changed)
#	shoot_timer.wait_time = respawn_cooldown


func on_movement_finished():
	state_chart.send_event("movement_finished")
	emit_signal("movement_finished")


func set_health(new_health):
	health = new_health
	if health > max_health:
		health = max_health
	emit_signal("health_changed", new_health, max_health)



func heal(amount):
	set_health(health + amount)


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
		await get_tree().create_timer(0.5, false).timeout
		can_shoot = true
#		shoot_timer.start()


func _physics_process(delta):
	set_health(health + regen*delta)
##	_movement_trait.manual_physics_process(delta)
#	if not is_instance_valid(aggro_target):
#		# TODO query space around the unit and switch aggro there
#		# if no one is close, set state to idle
#		state = "idle"
#		_movement_trait.move(builder.rally_point.global_position)
#	if state == "aggro":
#		if position.distance_to(aggro_target.position) < shoot_distance:
#			shoot(aggro_target)


func _on_attack_chasing_state_physics_processing(delta):
	if not is_instance_valid(aggro_target) or aggro_target.get_parent() == null:
		state_chart.send_event("target_lost")


func is_in_range(enemy):
	if get_global_position().distance_to(enemy.global_position) < shoot_distance:
		return true
	return false


func _on_shoot_state_physics_processing(delta):
	if is_in_range(aggro_target):
		shoot(aggro_target)
	else:
		state_chart.send_event("out_of_range")


func _on_shoot_state_entered():
	_movement_trait.stop()


func update_chasing_position():
	if can_update_chase:
		can_update_chase = false
		_movement_trait.move(aggro_target.get_global_position())
		await get_tree().create_timer(0.1, false).timeout
		can_update_chase = true


func _on_chasing_state_physics_processing(delta):
	update_chasing_position()
	if is_in_range(aggro_target):
		state_chart.send_event("in_range")


func move(movement_target: Vector2):
	_movement_trait.move(movement_target)


var HitEffectHero = preload("res://src/effects/hit_effect_hero.tscn")
func hit(damage, sender):
	
	var hitEffectHero = HitEffectHero.instantiate()
	get_tree().get_root().add_child(hitEffectHero)
	hitEffectHero.global_position = global_position
	
	set_health(health - damage)
	if health <= 0:
		queue_free()
		if is_instance_valid(builder):
			builder.unit_died()
	if is_instance_valid(sender) and state != "aggro":
		set_potential_target(sender)


func set_aggro_target(unit):
	aggro_target = unit
	move(unit.global_position)


#func _on_navigation_agent_2d_velocity_computed(safe_velocity):
#	velocity = safe_velocity
#	move_and_slide()

func query_surroundings_for_target():
	var surrounding_bodies = aggro_area.get_overlapping_areas()
	if surrounding_bodies.size() == 0:
		return false
	var target = GlobalUtils.find_closest(surrounding_bodies, get_global_position())
#		var target = query_surroundings_for_target()
	if target and is_instance_valid(target):
		set_potential_target(target)
		state_chart.send_event("found_target")


func _on_idle_state_entered():
	_movement_trait.stop()
	query_surroundings_for_target()
#	if target and is_instance_valid(target):
#		set_aggro_target(target)
#		state_chart.send_event("found_target")


func _on_moving_to_rally_state_entered():
	query_surroundings_for_target()
	move(builder.rally_point.global_position)
	

func set_potential_target(unit):
	potential_target = unit


func _on_attack_chasing_state_entered():
	if potential_target and is_instance_valid(potential_target):
		set_aggro_target(potential_target)


func _on_aggro_area_area_entered(area):
	if is_instance_valid(area) and area.is_in_group("enemy"):
		set_potential_target(area) 
		state_chart.send_event("found_target")
