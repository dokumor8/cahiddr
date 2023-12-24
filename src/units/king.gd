extends Area2D
@export var max_health = 200.0
@export var health = 200.0
var rng = RandomNumberGenerator.new()
var unit_name = "King"
var minimap_icon = "king"

signal health_changed(new_health, max_health)
signal died()


func _ready():
	$AnimatedSprite2D.play()
	randomize()


func set_health(new_health):
	if new_health <= 0:
		emit_signal("died")
		PlayerVariables.game_ended = true
		queue_free()
	emit_signal("health_changed", new_health, max_health)
	health = new_health


func heal(amount):
	set_health(health + amount)
	

var HitEffectHero = preload("res://src/effects/hit_effect_hero.tscn")
var DamageTextLabel = preload("res://src/effects/damage_text_label.tscn")
func hit(damage, _sender):
	
	var hitEffectHero = HitEffectHero.instantiate()
	get_tree().get_root().add_child(hitEffectHero)
	var shift_x = rng.randf_range(-10.0, 10.0)
	var shift_y = rng.randf_range(-10.0, 10.0)

	var damageTextLabel = DamageTextLabel.instantiate()
	var damage_text = str(damage)
	damageTextLabel.set_text(damage_text)
	damageTextLabel.global_position = global_position
	get_tree().get_root().add_child(damageTextLabel)
	

	hitEffectHero.global_position = global_position + Vector2(shift_x, shift_y)
	
#	global_translate()
	var rotation_shift = deg_to_rad(rng.randf_range(0, 360.0))
	hitEffectHero.global_rotation = rotation_shift
	
	set_health(health - damage)

