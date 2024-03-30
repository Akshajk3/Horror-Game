extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var impact_sound = $"impact sound"

const SPEED = 8.0

enum {
	IDLE,
	HUNT,
	CHASE,
	WANDER
}

@export var state = WANDER

var first_load = true

@export var hunt_distance = 8


func _physics_process(delta):
	if state == CHASE:
		chase()
	elif state == HUNT:
		hunt()
	elif state == WANDER:
		wander()
	else:
		idle()

func update_target_location(target_location):
	nav_agent.target_position = target_location

func chase():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	velocity = new_velocity
	move_and_slide()

func idle():
	pass

func move_toward_target():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()
	
	velocity = new_velocity
	move_and_slide()

func hunt():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	var distance = global_position.distance_to(next_location)
	
	if distance > hunt_distance:
		velocity = new_velocity
		move_and_slide()
	
	var chase_chance = randf_range(0, 1)
	if chase_chance == 1:
		state = CHASE

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
	state = CHASE
	impact_sound.play()

func _target_reached():
	return nav_agent.target_reached

func _on_visible_on_screen_notifier_3d_screen_entered():
	if state == HUNT:
		print("on_screen")
