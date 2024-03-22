extends Node3D

@onready var player = $Player

@onready var skinrunner = $Skinrunner

func _physics_process(delta):
	skinrunner.update_target_location(player.global_transform.origin)
