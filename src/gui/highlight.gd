extends Node2D

var _activated = false
var _forced = false

const HERO_CIRCLE_COLOR = Color.GREEN
const ENEMY_CIRCLE_COLOR = Color.RED
const DEFAULT_CIRCLE_COLOR = Color.WHITE

@onready var _unit = get_parent()
@onready var _marker = $HighlightMarker


func _ready():
#	_update_circle_color()

	_unit.mouse_entered.connect(_activate)
	_unit.mouse_exited.connect(_deactivate)
	_marker.hide()


func force():
	_forced = true
	_update()


func unforce():
	_forced = false
	_update()


func refresh():
	_update()


func _update_marker_color():
	if _unit.is_in_group("hero"):
		_marker.color = HERO_CIRCLE_COLOR
	elif _unit.is_in_group("enemy"):
		_marker.color = ENEMY_CIRCLE_COLOR
	else:
		_marker.color = DEFAULT_CIRCLE_COLOR


func _activate():
	_activated = true
	_update()


func _deactivate():
	_activated = false
	_update()


func _update():
	_update_marker_color()
	_marker.visible = _forced or _activated
