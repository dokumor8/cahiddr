extends "res://src/units/actor.gd"

var regen_increase_rate = 0.1
var health_increase_rate = 10
var shooting_speedup = 0.3

@export var animation_player: AnimationPlayer
@export var teleport_home: Node2D

var minimap_icon = "alert"
signal removed()

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	GlobalSignals.command_move.connect(walk_to)
	GlobalSignals.command_attack.connect(follow_command_attack)
	#attack_action = perform_attack
	died.connect(on_died)


func follow_command_attack(unit):
	print("attacking unit")
	attack(unit)

func _input(event):
	if event.is_action_pressed("cast_return_to_base"):
		state_chart.send_event("cast_command")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#
#func on_idle_state_entered():
	#var state_machine = _animation_tree["parameters/playback"]
	#state_machine.travel("idle")
	#
	
#func _on_attack_chasing_state_entered():
	#var state_machine = _animation_tree["parameters/playback"]
	#state_machine.travel("walk")


func on_died():
	removed.emit(self)


func level_up():
	PlayerVariables.hero_experience -= PlayerVariables.max_experience
	PlayerVariables.hero_level += 1
	PlayerVariables.max_experience = PlayerVariables.hero_level * 5
	max_health += health_increase_rate
	set_health(health + health_increase_rate)
	attack_damage += 0.5
	shots_per_second += shooting_speedup
	regen_rate += regen_increase_rate


func receive_exp(exp_value):
	PlayerVariables.hero_experience += exp_value
	if PlayerVariables.hero_experience >= PlayerVariables.max_experience:
		level_up()

#
#func on_moving_without_attacking_state_entered():
	#var state_machine = _animation_tree["parameters/playback"]
	#state_machine.travel("walk")


#func perform_attack():
	#var state_machine = _animation_tree["parameters/playback"]
	##state_machine.travel("shoot_punch")
	#state_machine.start("shoot_punch", true)
	##_animation_tree.set("parameters/TimeSeek/seek_request", 0.0)
	##state_machine.start()
	##animation_player.play("shoot_punch")


#func on_chasing_state_entered():
	#var state_machine = _animation_tree["parameters/playback"]
	#state_machine.travel("walk")



func _on_cast_success_state_entered():
	global_position = teleport_home.global_position
	state_chart.send_event("cast_success")
	pass # Replace with function body.


func _on_cooling_transition_pending(initial_delay, remaining_delay):
	GlobalSignals.cast_pending.emit(initial_delay, remaining_delay)


func _on_casting_state_entered():
	var state_machine = _animation_tree["parameters/playback"]
	state_machine.travel("casting")
