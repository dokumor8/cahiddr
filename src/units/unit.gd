extends CharacterBody2D

var selected = false
var target_object = 0
@onready var aggroed = false
var shot_count = 0

signal health_changed(new_health, max_health)
signal died()

var movement_speed: float = 100.0
var movement_target_position: Vector2 = Vector2(60.0, 180.0)

@onready var _movement_trait = $Movement
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var aggro_target: CharacterBody2D
@onready var shoot_timer = $Timer
@export var speed = 100
var stop_distance = 100.0
var shoot_distance = 150.0
var health = 4
var max_health = 4
var can_shoot = true
var is_aggroed = true
var unit_name = "Enemy"
var unit_exp_value = 2
var money_reward = 5
var _king


func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	animated_sprite.play()
	var root_node = get_tree().get_root()

	_king = root_node.get_node("/root/Main/GameWorld/King")
	
	if is_instance_valid(_king):
		set_aggro_target(_king)
	print("calling myready")
	_movement_trait.my_ready()
	health_changed.connect($HealthBar._on_health_changed)
#	print(_movement_trait.avoidance_enabled)


func select():
	selected = true
	$Selected.visible = true


func deselect():
	selected = false
	$Selected.visible = false


var Bullet = preload("res://src/enemy_bullet.tscn")
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



func _physics_process(_delta):
	if not is_aggroed:
		return
	if not is_instance_valid(aggro_target) or aggro_target.get_parent() == null:
		var root_node = get_tree().get_root()
		aggro_target = root_node.get_node("/root/Main/GameWorld/King")
		if aggro_target == null:
			is_aggroed = false
			return
	
	if position.distance_to(aggro_target.position) < shoot_distance:
		shoot(aggro_target)


func _on_aggro_area_body_entered(body):
	# change state to aggro
	if is_instance_valid(aggro_target) and aggro_target.is_in_group("king"):
		if body.is_in_group("hero") or body.is_in_group("defender"):
			set_aggro_target(body)
#			print("aggro_switch")
#		target_object = body
#		aggroed = true


func _on_timer_timeout():
	can_shoot = true


func _on_click_area_mouse_entered():
	select()


func _on_click_area_mouse_exited():
	deselect()


func set_health(new_health):
	health = new_health
	emit_signal("health_changed", new_health, max_health)


var HitEffectHero = preload("res://src/effects/hit_effect_hero.tscn")
func hit(damage, sender):

	
#	if is_instance_valid(sender) and not is_aggroed:
	if is_instance_valid(sender) and is_instance_valid(aggro_target) and aggro_target.is_in_group("king"):
		set_aggro_target(sender)

	
	var hitEffectHero = HitEffectHero.instantiate()
	get_tree().get_root().add_child(hitEffectHero)
	hitEffectHero.global_position = global_position
	set_health(health - damage)
	if health <= 0:
#		emit_signal("died")
		if is_instance_valid(sender) and sender.is_in_group("hero"):
			sender.receive_exp(unit_exp_value)
		queue_free()
		PlayerVariables.money += money_reward


func set_aggro_target(unit):
	aggro_target = unit
	_movement_trait.move(unit.global_position)
