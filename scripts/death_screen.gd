extends Control


func _process(delta):
	if Input.is_action_pressed("reload"):
		get_tree().change_scene_to_file("res://scenes/world.tscn")
	
	if Input.is_action_pressed("quit"):
		get_tree().quit()
