extends Node3D

@onready var player = $Player
@onready var skinrunner = $Skinrunner
@onready var collectors = $Collectors
@onready var nav_mesh = $NavigationRegion3D
@onready var abberation = $ColorRect
@onready var death_sound = $Deathsound
@onready var items_label = $HUD/Label

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	abberation.material.set_shader_parameter(("alpha"), lerp(0, 1, 0.2))
	player.too_loud.connect(too_loud)
	skinrunner.die.connect(die)

func _physics_process(delta):
	if skinrunner.state == skinrunner.CHASE:
		skinrunner.update_target_location(player.global_transform.origin)
	
	items_label.text = "Items Left: " + str(collectors.get_child_count())
	
	if collectors.get_child_count() == 0:
		win()

func too_loud(sound_position):
	print(sound_position)
	skinrunner.update_sound_source(sound_position)

func win():
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")

func die():
	death_sound.play()

func _on_deathsound_finished():
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
