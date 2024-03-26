extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

const SPEED = 5.0

enum {
	IDLE,
	HUNT,
	CHASE
}

@export var state = IDLE
var player_position

@export var hunt_distance = 8

func _physics_process(delta):
	if state == CHASE:
		chase()
	elif state == HUNT:
		hunt()
	else:
		idle()

func update_target_location(target_location):
	nav_agent.target_position = target_location
	player_position = target_location

func chase():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	velocity = new_velocity
	move_and_slide()

func idle():
	pass

func hunt():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	var distance = global_position.distance_to(next_location)
	
	if distance > hunt_distance:
		velocity = new_velocity
		move_and_slide()


func _on_area_3d_area_entered(area):
	#state = CHASE
	pass

func _target_reached():
	return nav_agent.target_reached

func _on_visible_on_screen_notifier_3d_screen_entered():
	if state == HUNT:
		print("on_screen")
