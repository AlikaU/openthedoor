extends RigidBody2D

var velocity = Vector2(0, -400)

func _ready():
	var hue = randf_range(0.4, 0.6)
	modulate = Color.from_hsv(hue, randf_range(0.3, 0.5), 1.0)

	rotation = randf_range(0, TAU)
	linear_velocity = Vector2(0, randf_range(60, -30))
	angular_velocity = randf_range(-1.5, 1.5)
