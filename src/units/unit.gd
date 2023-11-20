extends Area2D


var target_object = 0
@onready var aggroed = false
var shot_count = 0

signal health_changed(new_health, max_health)
signal died()
signal input_happened(event)
signal send_exp(coords, amount)

var movement_speed: float = 100.0
var movement_target_position: Vector2 = Vector2(60.0, 180.0)

@onready var _movement_trait = $Movement
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var aggro_target: Node2D
@onready var aggro_area = $AggroArea
@onready var game_world = find_parent("GameWorld")
var potential_target: Node2D

## The state chart
@onready var state_chart:StateChart = $StateChart

@export var speed = 100
var stop_distance = 100.0
var shoot_distance = 150.0
var health = 10
var max_health = 10
var unit_name = "Enemy"
var unit_exp_value = 2
var attack_damage = 4
var money_reward = 1
var _king = null
var _hero :Area2D = null
var shots_per_second = 0.87
var can_shoot = true
var can_update_chase = true


func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	animated_sprite.play()
	send_exp.connect(GlobalUtils.on_send_exp)

#	print("calling myready")
	_movement_trait.my_ready()
	health_changed.connect($HealthBar._on_health_changed)

	var root_node = get_tree().get_root()
	
	_king = game_world.find_child("King")
	_hero = game_world.find_child("Hero")


func set_parameters(parameters):
	
	max_health = parameters.get("health", max_health)
	set_health(max_health)
	attack_damage = parameters.get("attack_damage", attack_damage)
	shots_per_second = parameters.get("shots_per_second", shots_per_second)
	

var Bullet = preload("res://src/enemy_bullet.tscn")
func shoot(target):
	if can_shoot:
		var bul = Bullet.instantiate()
		var bullet_parameters = {
			"global_position": global_position,
			"speed": 600,
			"damage": attack_damage
		}
		bul.setup(self, target, bullet_parameters)
		game_world.add_child(bul)

		can_shoot = false
		await get_tree().create_timer(1.0 / shots_per_second, false).timeout
		can_shoot = true


func is_in_range(enemy):
	if get_global_position().distance_to(enemy.global_position) < shoot_distance:
		return true
	return false
	

func _on_shoot_state_physics_processing(delta):
	if is_in_range(aggro_target):
		shoot(aggro_target)
	else:
		state_chart.send_event("out_of_range")


#func _on_shoot_state_physics_processing():


#func _physics_process(_delta):
#	if not is_aggroed:
#		return
#	if not is_instance_valid(aggro_target) or aggro_target.get_parent() == null:
#		var root_node = get_tree().get_root()
#		aggro_target = game_world.find_child("King")
#		if aggro_target == null:
#			is_aggroed = false
#			return
	
#	if position.distance_to(aggro_target.position) < shoot_distance:
#		shoot(aggro_target)

## Finds the closest position to the given position from the given list of nodes.



func _on_aggro_area_area_entered(area):
	# change state to aggro
#	print(area)
	if is_instance_valid(aggro_target) and aggro_target.is_in_group("king"):
		if area.is_in_group("hero") or area.is_in_group("defender") or area.is_in_group("king"):
#			print(area)
			set_potential_target(area)
			state_chart.send_event("found_target")
#			print("aggro_switch")
#		target_object = body
#		aggroed = true


func query_surroundings_for_target():
	var surrounding_bodies = aggro_area.get_overlapping_areas()
	surrounding_bodies = surrounding_bodies.filter(
		func(area): return area.is_in_group("targetable_allies")
	)
	if surrounding_bodies.size() == 0:
		return false
	var target = GlobalUtils.find_closest(surrounding_bodies, get_global_position())
	return target


func set_health(new_health):
	health = new_health
	emit_signal("health_changed", new_health, max_health)


var HitEffectHero = preload("res://src/effects/hit_effect_hero.tscn")
func hit(damage, sender):
#	if is_instance_valid(sender) and not is_aggroed:
	if is_instance_valid(sender) and is_instance_valid(aggro_target) and aggro_target.is_in_group("king"):
		set_potential_target(sender)
		state_chart.send_event("found_target")

	var hitEffectHero = HitEffectHero.instantiate()
	get_tree().get_root().add_child(hitEffectHero)
	hitEffectHero.global_position = global_position
	set_health(health - damage)
	if health <= 0:
#		emit_signal("died")
		send_exp.emit(global_position, unit_exp_value)
#		if is_instance_valid(sender) and sender.is_in_group("hero"):
#			sender.receive_exp(unit_exp_value)
		PlayerVariables.money += money_reward
		queue_free()


func set_aggro_target(unit):
	aggro_target = unit
	_movement_trait.move(unit.global_position)


func update_chasing_position():
	if can_update_chase:
		can_update_chase = false
		_movement_trait.move(aggro_target.get_global_position())
		await get_tree().create_timer(0.1, false).timeout
		can_update_chase = true


func _on_chasing_state_physics_processing(delta):
	update_chasing_position()
#	print("chasing")
#	_movement_trait.manual_physics_process(delta)
	if is_in_range(aggro_target):
		state_chart.send_event("in_range")


func _on_idle_state_entered():
	_movement_trait.stop()


func _on_shoot_state_entered():
	_movement_trait.stop()


func _on_attack_chasing_state_physics_processing(delta):
	if not is_instance_valid(aggro_target) or aggro_target.get_parent() == null:
		state_chart.send_event("target_lost")


func _on_moving_to_king_state_entered():
	var target = query_surroundings_for_target()
	if target and is_instance_valid(target):
		set_potential_target(target)
		state_chart.send_event("found_target")
	
	if is_instance_valid(_king):
		set_aggro_target(_king)
	else:
		state_chart.send_event("no_king")


func set_potential_target(unit):
	potential_target = unit


func _on_attack_chasing_state_entered():
	if potential_target and is_instance_valid(potential_target):
		set_aggro_target(potential_target)

#
#func _on_root_state_input(event):
#	input_happened.emit(event)

