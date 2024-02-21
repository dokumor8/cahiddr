extends Node

# requests
signal deselect_all_units
signal setup_and_spawn_unit(unit, transform, player)
signal place_structure(structure_prototype)

# notifications
signal terrain_targeted(position)
signal unit_spawned(unit)
signal unit_targeted(unit)
signal unit_selected(unit)
signal unit_deselected(unit)
signal unit_died(unit)

signal broadcast_event(text)
signal remove_last_event()
signal cast_pending(total, current)
signal big_wave()

signal show_build_menu()

signal command_move(pos)
signal command_attack(unit)

var event_cooldowns = {}
var events = {
	"king_attacked":
	{
		"name": "king_attacked",
		"cooldown": 3,
		"text": "King is attacked!"
	}
}


func try_broadcasting_event(event_type, event_text):
	if event_type not in event_cooldowns:
		broadcast_event.emit(event_text)
		event_cooldowns[event_type] = 1
		await get_tree().create_timer(events[event_type]["cooldown"], false).timeout
		remove_last_event.emit()
		event_cooldowns.erase(event_type)

