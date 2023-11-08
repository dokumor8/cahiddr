extends CharacterBody2D

@export var speed = 250
var shoot_distance = 500
var stop_distance = 300
@onready var shoot_timer = $Timer
@onready var _movement_trait = $Movement
@onready var game_world = find_parent("GameWorld")
# TODO redo via navigation

signal health_changed(new_health, max_health)
signal movement_finished()
signal died()


var target = position
var moving = false
var max_health = 10.0
var health = 10.0
var state = "idle"
var aggro_target
var can_shoot = true
var unit_name = "Hero"
var shoot_damage = 1
var bullet_speed = 400

var shots_per_second = 1.5
var shooting_speedup = 0.3
var can_update_aggro = true


func _ready():
	$AnimatedSprite2D.play()
	_movement_trait.my_ready()
	_movement_trait.speed = 200
	health = max_health
	shoot_timer.wait_time = 1.0 / shots_per_second
	_movement_trait.movement_finished.connect(on_movement_finished)
#	shoot_timer.wait_time = respawn_cooldown


func on_movement_finished():
	emit_signal("movement_finished")


func walk_to(walk_marker):
	_movement_trait.move(walk_marker.global_position)
	aggro_target = null
	state = "moving"

func set_attack_target(enemy):
	aggro_target = enemy
	state = "aggro"
	_movement_trait.move(enemy.position)
	

func _physics_process(_delta):

	if state == "aggro" or state == "shooting":
		if not is_instance_valid(aggro_target):
			state = "idle"
		else:
			if position.distance_to(aggro_target.position) < shoot_distance:
				shoot(aggro_target)
			update_aggro_movement()
			print(can_update_aggro)


func update_aggro_movement():
	print("updating")
	if can_update_aggro:
		print("updating2")
		_movement_trait.move(aggro_target.global_position)
		can_update_aggro = false
		await get_tree().create_timer(0.2).timeout
		print("updating3")
		can_update_aggro = true


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
		var bullet_parameters = {
			"global_position": global_position,
			"speed": bullet_speed,
			"damage": shoot_damage
		}
		bul.setup(self, shoot_target, bullet_parameters)
		game_world.add_child(bul)
		
		can_shoot = false
		await get_tree().create_timer(1.0 / shots_per_second).timeout
		can_shoot = true


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


func level_up():
	PlayerVariables.hero_experience -= PlayerVariables.max_experience
	PlayerVariables.hero_level += 1
	PlayerVariables.max_experience = PlayerVariables.hero_level * 5
	health += 5
	max_health += 5
	shoot_damage += 1
	shots_per_second += shooting_speedup
	shoot_timer.wait_time = 1.0 / shots_per_second
	print("level up")


func receive_exp(exp_value):
	PlayerVariables.hero_experience += exp_value
	if PlayerVariables.hero_experience >= PlayerVariables.max_experience:
		level_up()
	
