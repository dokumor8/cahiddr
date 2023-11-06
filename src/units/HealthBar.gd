extends TextureProgressBar


func _on_health_changed(new_health, max_health):
	value = float(new_health)/ max_health * 100
