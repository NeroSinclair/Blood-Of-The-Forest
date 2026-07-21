extends Button

# Load scene-nya dulu
var pause_scene = preload("res://pausemenu.tscn")

func _on_pause_pressed():
	get_tree().paused = true
	var pause_instance = pause_scene.instantiate()
	get_tree().root.add_child(pause_instance) # Munculin di paling atas layar
