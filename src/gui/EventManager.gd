extends Control

@onready var event_list_panel = %EventListPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.broadcast_event.connect(add_event)
	GlobalSignals.remove_last_event.connect(remove_event)
	pass # Replace with function body.


func add_event(text):
	var item_name = Label.new()
	item_name.text = text
	item_name.size_flags_vertical = SIZE_SHRINK_END
	event_list_panel.add_child(item_name)


func remove_event():
	event_list_panel.get_children()[0].queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
