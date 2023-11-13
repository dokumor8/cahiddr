extends CanvasLayer
@onready var game_end_text = $VBoxContainer/CenterContainer/GameEndText
@onready var build_button = $VBoxContainer/HBoxContainer2/BuildButton
@onready var health_bar = $VBoxContainer/SelectContainer/CenterContainer/HealthBar
@onready var selected_unit_label = $VBoxContainer/SelectContainer/Label
@onready var money_label = $VBoxContainer/HBoxContainer/EssenceAmount
@onready var exp_label = $VBoxContainer/HBoxContainer3/ExpAmount
@onready var level_label = $VBoxContainer/HBoxContainer4/LevelAmount
@onready var restart_button = find_child("RestartButton")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if PlayerVariables.money >= PlayerVariables.building_cost:
		build_button.disabled = false
	else:
		build_button.disabled = true
	
	money_label.text = str(PlayerVariables.money)
	exp_label.text = str(PlayerVariables.hero_experience) + " / " + str(PlayerVariables.max_experience)
	level_label.text = str(PlayerVariables.hero_level)


func show_end_message():
	game_end_text.show()
	

func on_selected_health_changed(health, max_health):
	health_bar.value = 100.0 * health / max_health


func update_selected_unit(unit):
	health_bar.value = 100.0 * unit.health / unit.max_health
	selected_unit_label.text = unit.unit_name


func _on_restart_button_pressed():
	print("pressed")
#	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/main-menu/Main.tscn")
