extends Camera3D

@export var randomStrength: float = 0.2
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func apply_shake():
	shake_strength = randomStrength

func update_shake_strength(strength):
	randomStrength = strength

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		
		h_offset = randomOffset().x
		v_offset = randomOffset().y
	
	apply_shake()

func randomOffset() -> Vector3:
	return Vector3(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
