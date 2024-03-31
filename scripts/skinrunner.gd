extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var impact_sound = $"impact sound"
@onready var footstep_sound = $footsteps
@onready var animation_player = $monster_model/AnimationPlayer
@onready var chase_timer = $"Chase Timer"
@onready var light = $OmniLight3D
@onready var wander_timer = $"Wander Timer"

const SPEED = 6.0

enum {
	IDLE,
	CHASE,
	WANDER
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

func _ready():
	world_env = get_parent().get_node("WorldEnvironment")
	env = world_env.get_environment()

func _physics_process(delta):
	if state == CHASE:
		chase()
	elif state == WANDER:
		wander()
	elif state == IDLE:
		idle()

func update_target_location(target_location):
	nav_agent.target_position = target_location
	player_position = target_location

func chase():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	look_at(player_position, Vector3.UP, true)
	
	if animation_player.current_animation != "run":
		animation_player.play("run")
	
	velocity = new_velocity
	move_and_slide()

func move_to_random_position():
	print("moving")
	moving = true
	update_target_location(get_random_point())
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	look_at(new_velocity, Vector3.UP, true)
	
	velocity = new_velocity
	move_and_slide()

func idle():
	footstep_sound.stop()
	impact_sound.stop()
	
	if animation_player.current_animation != "idle":
		animation_player.play("idle")

func wander():
	chase()

func get_random_point():
	var map_rid = get_world_3d().navigation_map
	var random_point = Vector3(randf_range(0, 25), randf_range(0, 25), randf_range(0, 25))
	random_point = NavigationServer3D.map_get_closest_point(map_rid, random_point)
	print(transform.origin)
	print(random_point)
	return random_point

func _on_area_3d_area_entered(area):
	state = CHASE
	impact_sound.play()
	footstep_sound.play()
	chase_timer.start()
	env.volumetric_fog_emission = chase_color
	env.volumetric_fog_density = 0.6

func _on_chase_timer_timeout():
	impact_sound.stop()
	footstep_sound.stop()
	state = IDLE
	light.hide()
	env.volumetric_fog_emission = default_color
	env.volumetric_fog_density = 0.3

func _on_wander_timer_timeout():
	move_to_random_position()

func _on_navigation_agent_3d_target_reached():
	moving = false
