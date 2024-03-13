extends "res://src/units/actor.gd"
var _king = null


func _ready():
	super()
	_king = game_world.find_child("King")
	set_health(max_health)
	#attack_action = perform_attack


func init_attack_king():
	await get_tree().create_timer(0.1, false).timeout
	print("attack king")
	#attack(PlayerVariables.king)
	attack_move(PlayerVariables.king.global_position)
 

func _on_moving_to_king_state_entered():
	var target = query_surroundings_for_target()
	if target and is_instance_valid(target):
		set_potential_target(target)
		state_chart.send_event("found_target")
	
	if is_instance_valid(_king):
		attack(_king)
	else:
		state_chart.send_event("no_king")

#func perform_attack():
	#var state_machine = _animation_tree["parameters/playback"]
	#state_machine.start("attack", true)


func set_parameters(parameters):
	max_health = parameters.get("health", max_health)
	set_health(max_health)
	attack_damage = parameters.get("attack_damage", attack_damage)
	shots_per_second = parameters.get("shots_per_second", shots_per_second)


func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("right_click"):
		GlobalVar.unit_clicked_this_frame = true
		GlobalSignals.command_attack.emit(self)
		viewport.set_input_as_handled()
