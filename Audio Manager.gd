extends Node3D


@export var stream : AudioStream
@onready var timer = $"Stinger Timer"

@export var player : CharacterBody3D

func _ready():
	var random_time = get_random_time(0, 10)
	timer.wait_time = random_time
	timer.start()

func play_sound(stream: AudioStream):
	var instance = AudioStreamPlayer3D.new()
	instance.transform.origin = player.transform.origin + random_position()
	instance.stream = stream
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.play()

func remove_node(instance: AudioStreamPlayer3D):
	instance.queue_free()
	timer.wait_time = get_random_time(0, 10)

func _on_stinger_timer_timeout():
	play_sound(stream)

func get_random_time(start, finish):
	return randf_range(start, finish)

func random_position():
	return Vector3(randf_range(0, 10), randf_range(0, 10), randf_range(0, 10))
