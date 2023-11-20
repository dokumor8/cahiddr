extends Node2D

@onready var _damager = get_parent()
@onready var damaging_timer = $Timer
@onready var damaging_area = $DamagingArea
var damaging_amount = 10

func _ready():
	damaging_timer.wait_time = 3.1415
	damaging_timer.start()

# every N seconds sends a healing effect around itself
# always, unless the game is paused
#	await get_tree().create_timer(1, false).timeout


var DamagingEffect = preload("res://src/effects/damaging_wave.tscn")
func make_damaging_wave():
	var damagingEffect = DamagingEffect.instantiate()
	get_tree().get_root().add_child(damagingEffect)
	damagingEffect.global_position = global_position

	var areas = damaging_area.get_overlapping_areas()
	for area in areas:
		print(area)
		if area.is_in_group("enemy"):
			area.hit(damaging_amount, _damager)


func _on_timer_timeout():
	make_damaging_wave()
