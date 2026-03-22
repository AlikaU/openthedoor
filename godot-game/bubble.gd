extends RigidBody2D

func _ready():
    var hue = randf_range(0.4, 0.6)
    modulate = Color.from_hsv(hue, randf_range(0.3, 0.5), 1.0)

    rotation = randf_range(0, TAU)
    linear_velocity = Vector2(randf_range(30, 120), randf_range(-150, -100))
    angular_velocity = randf_range(-1.5, 1.5)
