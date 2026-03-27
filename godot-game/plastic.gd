extends "res://trash.gd"

func _apply_visuals():
	modulate = Color.from_hsv(randf_range(0.55, 0.65), randf_range(0.1, 0.3), 1.0)
