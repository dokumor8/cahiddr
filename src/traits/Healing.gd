extends Node2D

@onready var _healer = get_parent()
@onready var healing_timer = $Timer
@onready var healing_area = $HealingArea
var healing_amount = 10

func _ready():
	healing_timer.wait_time = 5
	healing_timer.start()
	pass

# every N seconds sends a healing effect around itself
# always, unless the game is paused
#	await get_tree().create_timer(1, false).timeout


var HealingEffect = preload("res://src/effects/heal_effect.tscn")
func make_healing_wave():
	var healingEffect = HealingEffect.instantiate()
	get_tree().get_root().add_child(healingEffect)
	healingEffect.global_position = global_position

	var areas = healing_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("targetable_allies"):
			area.heal(healing_amount)


func _on_timer_timeout():
	make_healing_wave()
