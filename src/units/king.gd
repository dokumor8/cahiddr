extends CharacterBody2D
@export var health = 100
var rng = RandomNumberGenerator.new()


func _ready():
	randomize()
	pass # Replace with function body.


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
	
	health -= damage
	
	if health <= 0:
		queue_free()
		PlayerVariables.game_ended = true
