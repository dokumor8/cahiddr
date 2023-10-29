extends CanvasLayer
@onready var game_end_text = $VBoxContainer/CenterContainer/GameEndText
@onready var button = $VBoxContainer/HBoxContainer2/BuildButton
@onready var health_bar = $VBoxContainer/SelectContainer/CenterContainer/HealthBar
@onready var selected_unit_label = $VBoxContainer/SelectContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_end_message():
	game_end_text.show()
	

func on_selected_health_changed(health, max_health):
	health_bar.value = 100.0 * health / max_health


func update_selected_unit(unit):
	health_bar.value = 100.0 * unit.health / unit.max_health
	selected_unit_label.text = unit.unit_name
