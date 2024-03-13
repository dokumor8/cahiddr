extends Node
var final_wave_timer: SceneTreeTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	final_wave_timer = get_tree().create_timer(500, false)
	await final_wave_timer.timeout
	GlobalSignals.big_wave.emit()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#print(final_wave_timer.time_left)
