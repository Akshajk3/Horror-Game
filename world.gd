extends Node3D

@onready var player = $Player
@onready var skinrunner = $Skinrunner


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	skinrunner.update_target_location(player.global_transform.origin)


func get_random_position():
	return Vector3(player.position.x + randf_range(-100, 100), player.position.y, player.position.z + randf_range(-100, 100))
