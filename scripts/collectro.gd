extends Node3D

signal collected()

@onready var pickup_sfx = $AudioStreamPlayer3D

func _on_area_3d_area_entered(area):
	collected.emit()
	pickup_sfx.play()
	hide()


func _on_audio_stream_player_3d_finished():
	queue_free()
