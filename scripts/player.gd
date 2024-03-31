extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var footsteps = $footsteps_walk
@onready var footsteps_run = $footsteps_run
@onready var walk_timer = $walk_timer
@onready var breath = $breath_sfx
@onready var animation_player = $AnimationPlayer
@onready var flashlight = $Head/Hand/flashlight_model/flashlight
@onready var flash_on = $flash_on
@onready var flash_off = $flash_off

const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.0
const JUMP_VELOCITY = 4.5

@export var MOUSE_SENS = 0.005

var gravity = 10

const BOB_FREQ = 2.5
const BOB_AMP = 0.08
var t_bob = 0.0

var speed = WALK_SPEED

var walk_sound = true

var sprinting = false

var light = true

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENS)
		head.rotate_x(-event.relative.y * MOUSE_SENS)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

func _ready():
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		sprinting = true
	else:
		speed = WALK_SPEED
		sprinting = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "front", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if walk_sound == true:
			if sprinting:
				if footsteps_run.playing == false:
					footsteps.stop()
					footsteps_run.play()
					if breath.playing == false:
						breath.play()
			else:
				walk_sound = false
				breath.stop()
				footsteps_run.stop()
				footsteps.play()
				walk_timer.start()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		footsteps.stop()
		footsteps_run.stop()
		breath.stop()
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("light"):
		light = !light
		flash_on.stop()
		flash_off.stop()
		if light:
			flash_on.play()
			flashlight.show()
		else:
			flash_off.play()
			flashlight.hide()
		
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	if direction:
		animation_player.stop()
		camera.transform.origin = _headbob(t_bob)
	elif not animation_player.current_animation == "idle":
		camera.transform.origin = Vector3.ZERO
		animation_player.play("idle")
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos


func _on_walk_timer_timeout():
	walk_sound = true
