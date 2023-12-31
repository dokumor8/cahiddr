extends Area2D

@export var speed = 250
var shoot_distance = 300
var stop_distance = 300
@onready var _movement_trait = $Movement
@onready var aggro_area = $AggroArea
@onready var game_world = find_parent("GameWorld")
var potential_target: Node2D

signal health_changed(new_health, max_health)
signal movement_finished()
signal died()
signal input_happened(event)



@onready var state_chart:StateChart = $StateChart
@onready var _king:Area2D
var target = position
var moving = false
var max_health = 45.0
var health = 45.0
var state = "idle"
var aggro_target
var can_shoot = true
var unit_name = "Hero"
var shoot_damage = 3
var bullet_speed = 1000
var regen = 1 # per second
var regen_increase_rate = 0.1
var health_increase_rate = 10

var shots_per_second = 1.5
var shooting_speedup = 0.3
var can_update_chase = true
var minimap_icon = "alert"


func _ready():
	$AnimatedSprite2D.play()
	_movement_trait.my_ready()
	_movement_trait.speed = 200
	health_changed.connect($HealthBar._on_health_changed)
	set_health(max_health)
	
#	health = max_health
#	shoot_timer.wait_time = 1.0 / shots_per_second
	_movement_trait.movement_finished.connect(on_movement_finished)
#	shoot_timer.wait_time = respawn_cooldown


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
#	state = "moving"


func attack(enemy):
	aggro_target = enemy
#	state = "aggro"
	state_chart.send_event("attack_command")
	if not is_in_range(enemy):
		_movement_trait.move(enemy.global_position)
	

func set_potential_target(body):
	potential_target = body


func _physics_process(delta):
	set_health(health + regen*delta)
#	if state == "aggro" or state == "shooting":
#		if not is_instance_valid(aggro_target):
#			state = "idle"
#		else:
#			if position.distance_to(aggro_target.position) < shoot_distance:
#				shoot(aggro_target)
#			update_aggro_movement()
#			print(can_update_aggro)


func _on_aggro_area_area_entered(area):
#	print("hero aggro")
#	print(area)
	if is_instance_valid(area):
#		print("hero aggro2")
#		print(area.is_in_group("enemy"))
		if area.is_in_group("enemy"):
#			print("hero aggro3")
			set_potential_target(area)
			state_chart.send_event("found_target")


func is_in_range(enemy):
	if get_global_position().distance_to(enemy.global_position) < shoot_distance:
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
	

var HeroBullet = preload("res://src/hero_bullet.tscn")
func shoot(shoot_target):
	if can_shoot:
		state = "shooting"
		var bul = HeroBullet.instantiate()
		var bullet_parameters = {
			"global_position": global_position,
			"speed": bullet_speed,
			"damage": shoot_damage
		}
		bul.setup(self, shoot_target, bullet_parameters)
		game_world.add_child(bul)
		
		can_shoot = false
		await get_tree().create_timer(1.0 / shots_per_second, false).timeout
		can_shoot = true


var HitEffectHero = preload("res://src/effects/hit_effect_hero.tscn")
func hit(damage, _sender):
	
	var hitEffectHero = HitEffectHero.instantiate()
	game_world.add_child(hitEffectHero)
	hitEffectHero.global_position = global_position
	set_health(health - damage)
#	print(health)


func level_up():
	PlayerVariables.hero_experience -= PlayerVariables.max_experience
	PlayerVariables.hero_level += 1
	PlayerVariables.max_experience = PlayerVariables.hero_level * 5
	max_health += health_increase_rate
	set_health(health + health_increase_rate)
	shoot_damage += 0.5
	shots_per_second += shooting_speedup
	regen += regen_increase_rate
#	shoot_timer.wait_time = 1.0 / shots_per_second
#	print("level up")


func receive_exp(exp_value):
	PlayerVariables.hero_experience += exp_value
	if PlayerVariables.hero_experience >= PlayerVariables.max_experience:
		level_up()
	


func _on_attack_chasing_state_entered():
	if potential_target and is_instance_valid(potential_target):
		attack(potential_target)



#func _on_input_event(viewport, event, shape_idx):
#	print("event")
#	print(event)
#	print(shape_idx)
#	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
#		print("selected")

#
#
#func _on_root_state_input(event):
#	input_happened.emit(event)


func _on_input_event(viewport, event, shape_idx):
#	print(event)
	pass # Replace with function body.
