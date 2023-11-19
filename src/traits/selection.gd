@tool
extends Node2D
@onready var _unit = get_parent()
@export var width :int = 10
@export var height :int = 10

@onready var _rect = $Rectangle2D

var _selected = false

func _ready():
	_update_rect_params()
	if Engine.is_editor_hint():
		return
	GlobalSignals.deselect_all_units.connect(deselect)
	_unit.input_event.connect(_on_input_event)
#	print("connected input")
	_rect.hide()
#	var texture:GradientTexture2D = _sprite.texture
#	var gradient = texture.gradient
#	gradient.set_color(0, Color("red"))
#	texture.set_width(10)
#	texture.set_height(10)
	pass



func select():
	if _selected:
		return
	_selected = true
	if not _unit.is_in_group("selected_units"):
		_unit.add_to_group("selected_units")
	_update_rect_params()
	_rect.show()
	if "selected" in _unit:
		_unit.selected.emit()
	GlobalSignals.unit_selected.emit(_unit)


func deselect():
#	print("deselected")
	if not _selected:
		return
	_selected = false
	if _unit.is_in_group("selected_units"):
		_unit.remove_from_group("selected_units")
	_rect.hide()
	if "deselected" in _unit:
		_unit.deselected.emit()
	GlobalSignals.unit_deselected.emit(_unit)


func _update_rect_params():
	if _rect == null:
		return
	_rect.width = width
	_rect.height = height
	_rect.fill = false


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
#		print("right click caught here")
		pass
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
#		print("selected")
		GlobalSignals.deselect_all_units.emit()
		select()
