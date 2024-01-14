extends Area2D

@export var unit_name: String = ""
@export var aggro_area: Area2D = null
@export var state_chart: StateChart = null
@export var health_bar: TextureProgressBar = null
@export var enemy_unit_type: String = ""
@export var movement_speed = 150.0
@export var max_health = 100.0
@export var regen_rate = 0.0
@export var attack_distance = 300.0
@export var attack_damage = 3.0
@export var shots_per_second = 1.5
@export var bullet_speed = 1000.0

@export var state_idle: AtomicState = null
@export var state_chasing: AtomicState = null
@export var state_shoot: AtomicState = null
@export var state_attack_chasing: CompoundState = null


@onready var _movement_trait = $Movement
@onready var game_world = find_parent("GameWorld")

signal health_changed(new_health, max_health)
signal movement_finished()
signal died()
signal input_happened(event)

# internal
var potential_target: Node2D
var aggro_target = null
var health: float = 0.0
var target = position
var can_shoot = true
var can_update_chase = true

var HeroBullet = preload("res://src/hero_bullet.tscn")
var HitEffectHero = preload("res://src/effects/hit_effect_hero.tscn")


func _ready():
	_movement_trait.my_ready()
	_movement_trait.speed = movement_speed
	health_changed.connect(health_bar._on_health_changed)
	set_health(max_health)
	
	aggro_area.area_entered.connect(_on_aggro_area_area_entered)
	state_idle.state_entered.connect(_on_idle_state_entered)
	state_shoot.state_entered.connect(_on_shoot_state_entered)
	state_shoot.state_physics_processing.connect(_on_shoot_state_physics_processing)
	state_chasing.state_physics_processing.connect(_on_chasing_state_physics_processing)
	state_attack_chasing.state_entered.connect(_on_attack_chasing_state_entered)
	state_attack_chasing.state_physics_processing.connect(_on_attack_chasing_state_physics_processing)

	_movement_trait.movement_finished.connect(on_movement_finished)


func on_movement_finished():
	state_chart.send_event("movement_finished")
	emit_signal("movement_finished")


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


func walk_to(walk_marker):
	state_chart.send_event("move_command")
	_movement_trait.move(walk_marker.global_position)
	aggro_target = null


func attack(enemy):
	aggro_target = enemy
	state_chart.send_event("attack_command")
	if not is_in_range(enemy):
		_movement_trait.move(enemy.global_position)
	

func set_potential_target(body):
	potential_target = body


func _physics_process(delta):
	set_health(health + regen_rate * delta)


func _on_aggro_area_area_entered(area):
	if is_instance_valid(area):
		if area.is_in_group(enemy_unit_type):
			set_potential_target(area)
			state_chart.send_event("found_target")


func is_in_range(enemy):
	if get_global_position().distance_to(enemy.global_position) < attack_distance:
		return true
	return false


func _on_shoot_state_physics_processing(delta):
	if is_in_range(aggro_target):
		shoot(aggro_target)
	else:
		state_chart.send_event("out_of_range")


func _on_idle_state_entered():
	_movement_trait.stop()
	var target = query_surroundings_for_target()
	if target and is_instance_valid(target):
		attack(target)
		state_chart.send_event("found_target")


func _on_shoot_state_entered():
	_movement_trait.stop()


func _on_attack_chasing_state_physics_processing(delta):
	if not is_instance_valid(aggro_target) or aggro_target.get_parent() == null:
		state_chart.send_event("target_lost")


func query_surroundings_for_target():
	var surrounding_bodies = aggro_area.get_overlapping_areas()
	if surrounding_bodies.size() == 0:
		return false
	var target = GlobalUtils.find_closest(surrounding_bodies, get_global_position())
	return target


func set_health(new_health):
	health = new_health
	if health > max_health:
		health = max_health
	emit_signal("health_changed", new_health, max_health)

	if health <= 0:
		emit_signal("died")


func heal(amount):
	set_health(health + amount)
	

func shoot(shoot_target):
	if can_shoot:
		var bul = HeroBullet.instantiate()
		var bullet_parameters = {
			"global_position": global_position,
			"speed": bullet_speed,
			"damage": attack_damage
		}
		bul.setup(self, shoot_target, bullet_parameters)
		game_world.add_child(bul)
		
		can_shoot = false
		await get_tree().create_timer(1.0 / shots_per_second, false).timeout
		can_shoot = true


func hit(damage, _sender):
	var hitEffectHero = HitEffectHero.instantiate()
	game_world.add_child(hitEffectHero)
	hitEffectHero.global_position = global_position
	set_health(health - damage)
	state_chart.send_event("found_target")
#	print(health)


func _on_attack_chasing_state_entered():
	if potential_target and is_instance_valid(potential_target):
		attack(potential_target)
