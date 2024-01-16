extends "res://src/units/actor.gd"


func _ready():
	super()
	attack_action = perform_attack


func perform_attack():
	var state_machine = _animation_tree["parameters/playback"]
	state_machine.start("attack", true)


func _process(delta):
	pass
