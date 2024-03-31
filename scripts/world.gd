extends Node3D

@onready var player = $Player
@onready var skinrunner = $Skinrunner
@onready var collectors = $Collectors
@onready var nav_mesh = $NavigationRegion3D
@onready var abberation = $ColorRect

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	abberation.material.set_shader_parameter(("alpha"), lerp(0, 1, 0.2))

func _physics_process(delta):
	skinrunner.update_target_location(player.global_transform.origin)
	
	if collectors.get_child_count() == 0:
		get_tree().quit()
