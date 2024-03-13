extends Control
@onready var cancel_button = $PanelContainer/MarginContainer/VBoxContainer/CancelButton
@onready var build_def_button = $PanelContainer/MarginContainer/VBoxContainer/DefBarButton
@onready var build_tower_button = $PanelContainer/MarginContainer/VBoxContainer/ArcherTowerButton

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	GlobalSignals.show_build_menu.connect(show)
	cancel_button.pressed.connect(hide)
	build_def_button.pressed.connect(start_build_def)
	build_tower_button.pressed.connect(start_build_tower)


func start_build_def():
	hide()
	start_build_mode("defender_building")


func start_build_tower():
	hide()
	start_build_mode("archer_tower")


func start_build_mode(building):
	GlobalVar.cursor_mode = "build"
	GlobalVar.building = building
