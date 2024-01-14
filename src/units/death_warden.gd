extends "res://src/units/actor.gd"

@export var _animation_tree: AnimationTree
var regen_increase_rate = 0.1
var health_increase_rate = 10
var shooting_speedup = 0.3

var minimap_icon = "alert"
signal removed()

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	died.connect(on_died)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_idle_state_entered():
	var state_machine = _animation_tree["parameters/playback"]
	state_machine.travel("idle")
	
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
	


func on_moving_without_attacking_state_entered():
	var state_machine = _animation_tree["parameters/playback"]
	state_machine.travel("walk")



func on_shoot_state_entered():
	var state_machine = _animation_tree["parameters/playback"]
	state_machine.travel("shoot_punch")


func on_chasing_state_entered():
	var state_machine = _animation_tree["parameters/playback"]
	state_machine.travel("walk")
