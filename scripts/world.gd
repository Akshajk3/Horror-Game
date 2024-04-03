extends Node3D

@onready var player = $Player
@onready var skinrunner = $Skinrunner
@onready var collectors = $Collectors
@onready var nav_mesh = $nav
@onready var abberation = $ColorRect
@onready var death_sound = $Deathsound
@onready var items_label = $HUD/Label
@onready var death_rect = $"HUD/death Rect"
@onready var spawn_points = $"monster spawn points"

func _ready():
	skinrunner.update_target_location(player.global_transform.origin)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	abberation.material.set_shader_parameter(("alpha"), lerp(0, 1, 0.2))
	player.too_loud.connect(too_loud)
	skinrunner.die.connect(die)
	skinrunner.run.connect(run)
	for i in range(collectors.get_child_count()):
		print(i)
		collectors.get_child(i).collected.connect(collect)
	
	var index = randi_range(0, spawn_points.get_child_count() - 1)
	var spawn = spawn_points.get_child(index)
	skinrunner.transform.origin = spawn.transform.origin
	print(skinrunner.transform.origin)

func _physics_process(delta):
	if skinrunner.state == skinrunner.CHASE:
		skinrunner.update_target_location(player.global_transform.origin)
	
	items_label.text = "Items Left: " + str(collectors.get_child_count())
	
	if collectors.get_child_count() == 0:
		win()
	
	var monster_distance = skinrunner.transform.origin.distance_to(player.transform.origin)
	var shake_strength = 15 - monster_distance
	shake_strength = maxf(shake_strength, 0)
	shake_strength /= 100
	player.camera.update_shake_strength(shake_strength)

func too_loud(sound_position):
	print(sound_position)
	skinrunner.update_sound_source(sound_position)

func win():
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")

func die():
	death_rect.show()
	death_sound.play()

func run():
	pass

func collect():
	skinrunner.update_sound_source(player.transform.origin)
	skinrunner.SPEED += 2

func _on_deathsound_finished():
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
