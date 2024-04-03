extends Control

@onready var menu = $Menu
@onready var how_to_play = $"How To Play"

func _on_play_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_quit_game_button_pressed():
	get_tree().quit()

func _on_how_to_play_button_pressed():
	menu.hide()
	how_to_play.show()


func _on_back_button_pressed():
	how_to_play.hide()
	menu.show()
