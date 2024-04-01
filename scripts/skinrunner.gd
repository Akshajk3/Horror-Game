extends CharacterBody3D

signal die()

@onready var nav_agent = $NavigationAgent3D
@onready var impact_sound = $"impact sound"
@onready var footstep_sound = $footsteps
@onready var animation_player = $monster_model/AnimationPlayer
@onready var chase_timer = $"Chase Timer"
@onready var light = $OmniLight3D
@onready var wander_timer = $"Wander Timer"
@onready var sound_timer = $"Sound Timer"

const SPEED = 6.0
const ACCEL = 2.0

enum {
	IDLE,
	CHASE,
	WANDER,
	SOUND
}

@export var state = WANDER
@export var hunt_distance = 8
@export var default_color = Color(0, 0, 0)
@export var chase_color = Color(0, 0, 0)

var first_load = true
var player_position : Vector3
var moving = false
var world_env : WorldEnvironment
var env : Environment
var wander_position : Vector3
var arrived = false
var sound_source : Vector3
var can_hear = true

func _ready():
	world_env = get_parent().get_node("WorldEnvironment")
	env = world_env.get_environment()
	state = WANDER

func _physics_process(delta):
	if state == CHASE:
		chase(delta)
	elif state == WANDER:
		wander(delta)
	elif state == SOUND:
		sound()
	elif state == IDLE:
		idle()

func update_target_location(target_location):
	nav_agent.target_position = target_location
	player_position = target_location

func chase(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	look_at(player_position, Vector3.UP, true)
	
	if animation_player.current_animation != "run":
		animation_player.play("run")
	
	velocity = velocity.lerp(new_velocity * SPEED, ACCEL * delta)
	move_and_slide()

func move_to_random_position(delta):
	moving = true
	var direction = Vector3()
	
	nav_agent.target_position = wander_position
	
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	look_at(nav_agent.get_next_path_position(), Vector3.UP, true)
	
	velocity = velocity.lerp(direction * SPEED, ACCEL * delta)
	
	move_and_slide()

func sound():
	if arrived:
		state = WANDER
	else:
		investigate_sound()
		animation_player.play("run")

func investigate_sound():
	moving = true
	var direction = Vector3()
	
	nav_agent.target_position = sound_source
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	look_at(nav_agent.get_next_path_position(), Vector3.UP, true)
	
	velocity = velocity.lerp(direction * SPEED, ACCEL * get_physics_process_delta_time())
	move_and_slide()

func update_sound_source(sound_pos):
	if can_hear:
		sound_source = sound_pos
		state = SOUND

func idle():
	footstep_sound.stop()
	impact_sound.stop()
	
	if animation_player.current_animation != "idle":
		animation_player.play("idle")

func wander(delta):
	if wander_position != Vector3.ZERO and arrived == false:
		move_to_random_position(delta)
	if moving:
		if animation_player.current_animation != "run":
			animation_player.play("run")
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")

func get_random_point():
	var map_rid = get_world_3d().navigation_map
	var random_point = Vector3(randf_range(-75, 60), randf_range(0, 25), randf_range(-65, 70))
	random_point = NavigationServer3D.map_get_closest_point(map_rid, random_point)
	return random_point

func start_chase():
	state = CHASE
	impact_sound.play()
	footstep_sound.play()
	chase_timer.start()
	env.volumetric_fog_emission = chase_color
	env.volumetric_fog_density = 0.6

func _on_area_3d_area_entered(area):
	start_chase()

func stop_chase():
	impact_sound.stop()
	footstep_sound.stop()
	state = WANDER
	light.hide()
	env.volumetric_fog_emission = default_color
	env.volumetric_fog_density = 0.3
	sound_timer.start()

func _on_chase_timer_timeout():
	stop_chase()

func _on_wander_timer_timeout():
	wander_position = get_random_point()
	arrived = false

func _on_navigation_agent_3d_target_reached():
	moving = false
	arrived = true
	wander_timer.start()

func _on_chase_cooldown_timeout():
	start_chase()

func _on_sound_timer_timeout():
	can_hear = true


func _on_kill_area_area_entered(area):
	die.emit()
