extends Node2D


signal health_changed(new_health, max_health)
var spawn_width = 20
var spawn_height = 40
@export var spawn_area :RectangleShape2D
var rng = RandomNumberGenerator.new()
var Unit = preload("res://src/units/unit.tscn")
var camp_level = 2
@onready var state_chart = $StateChart
var max_health = 200.0
var health = 200.0
var money_reward = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	health_changed.connect($HealthBar._on_health_changed)
	seed(1)


func set_health(new_health):
	health = new_health
	emit_signal("health_changed", new_health, max_health)


func spawn_wave(amount, delay):
	spawn_enemy()
	for i in amount - 1:
		await get_tree().create_timer(delay, false).timeout
		spawn_enemy()
	

func spawn_enemy():
	var unit = Unit.instantiate()

	var game_world = find_parent("GameWorld")
	game_world.add_child(unit)

	var x_spawn = rng.randi() % spawn_width
	var y_spawn = rng.randi() % spawn_height

	unit.global_position = global_position + Vector2(x_spawn, y_spawn)


var HitEffectHero = preload("res://src/effects/hit_effect_hero.tscn")
func hit(damage, sender):

	var hitEffectHero = HitEffectHero.instantiate()
	get_tree().get_root().add_child(hitEffectHero)
	hitEffectHero.global_position = global_position
	set_health(health - damage)
	if health <= 0:
#		emit_signal("died")
		PlayerVariables.money += money_reward
		queue_free()


func _on_send_wave_state_entered():
#	print("spawning unit")
	await spawn_wave(camp_level, 0.1)
	state_chart.send_event("building_finished")


func _on_upgrade_state_entered():
	camp_level += 1
#	print("camp level up", camp_level)
	state_chart.send_event("upgrading_finished")


func _on_building_units_state_entered():
#	print("started_building")
	state_chart.send_event("building_started")
	pass # Replace with function body.


func _on_upgrading_state_entered():
#	print("upgrading_started")
	state_chart.send_event("upgrading_started")
	pass # Replace with function body.
