extends CanvasLayer
@onready var game_end_text = $%GameEndText
@onready var build_button = $%BuildButton
@onready var health_bar = $%HealthBar
@onready var exp_bar = $%ExpBar
@onready var money_label = $%EssenceAmount
#@onready var exp_label = $VBoxContainer/HBoxContainer3/ExpAmount
@onready var level_label = $%LevelAmount
@onready var restart_button = $%RestartButton
@onready var rally_button = $%RallyButton
@onready var return_button = %ReturnSkillButton
@onready var timer_label = %TimerLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.cast_pending.connect(update_return_cooldown)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if PlayerVariables.money >= PlayerVariables.building_cost:
		build_button.disabled = false
	else:
		build_button.disabled = true
	
	money_label.text = str(PlayerVariables.money)
	if is_instance_valid(exp_bar):
		exp_bar.value = 100.0 * PlayerVariables.hero_experience / PlayerVariables.max_experience
#	exp_label.text = str(PlayerVariables.hero_experience) + " / " + str(PlayerVariables.max_experience)
	level_label.text = str(PlayerVariables.hero_level)
	
	if GlobalVar.event_manager:
		var time_left = str(snappedf(GlobalVar.event_manager.final_wave_timer.time_left, 1))
		timer_label.text = time_left


func update_return_cooldown(total, current):
	print(current)
	return_button.update_cooldown(100.0 * current / total)
	pass


func show_end_message():
	game_end_text.show()
	

func on_selected_health_changed(health, max_health):
	health_bar.value = 100.0 * health / max_health


func update_selected_unit(unit):
	pass
#	health_bar.value = 100.0 * unit.health / unit.max_health
#	selected_unit_label.text = unit.unit_name


func _on_restart_button_pressed():
	
	PlayerVariables.money = PlayerVariables.default_money
	PlayerVariables.hero_experience = PlayerVariables.default_hero_experience
	PlayerVariables.max_experience = PlayerVariables.default_max_experience
	PlayerVariables.hero_level = PlayerVariables.default_hero_level
#	print("pressed")
#	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/main-menu/Main.tscn")
