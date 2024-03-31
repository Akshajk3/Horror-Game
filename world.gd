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
	

func get_random_position():
	var map = nav_mesh.get_navigation_map()
	var random_position = Vector3(player.position.x + randf_range(-12, 12), player.position.y, player.position.z + randf_range(-12, 12))
	random_position = NavigationServer3D.map_get_closest_point(map, random_position)
	print(random_position)
	return random_position

