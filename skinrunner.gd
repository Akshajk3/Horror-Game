extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var impact_sound = $"impact sound"
@onready var footstep_sound = $footsteps
@onready var animation_player = $monster_model/AnimationPlayer
@onready var chase_timer = $"Chase Timer"
@onready var light = $OmniLight3D

const SPEED = 6.0

enum {
	IDLE,
	CHASE,
	WANDER
}

@export var state = WANDER
@export var hunt_distance = 8

var first_load = true
var player_position : Vector3

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

func idle():
	footstep_sound.stop()
	impact_sound.stop()
	
	if animation_player.current_animation != "idle":
		animation_player.play("idle")

func move_toward_target():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()
	
	velocity = new_velocity
	move_and_slide()

func wander():
	if first_load:
		print("started")
		update_target_location(get_parent_node_3d().player.global_position)
		move_toward_target()
	elif nav_agent.is_navigation_finished():
		print("arrived")
		get_parent_node_3d().get_random_position()
		move_toward_target()
	first_load = false

func _on_area_3d_area_entered(area):
	print("near")
	state = CHASE
	impact_sound.play()
	footstep_sound.play()
	chase_timer.start()
	light.show()

func _target_reached():
	return nav_agent.target_reached

func _on_chase_timer_timeout():
	print("hello")
	impact_sound.stop()
	footstep_sound.stop()
	state = IDLE
	light.hide()
