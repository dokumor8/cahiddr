extends CanvasLayer
@onready var game_end_text = $VBoxContainer/CenterContainer/GameEndText

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_end_message():
	game_end_text.show()
