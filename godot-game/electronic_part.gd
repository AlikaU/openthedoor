extends "res://trash.gd"

func _apply_visuals():
	modulate = Color.from_hsv(randf_range(0.25, 0.38), randf_range(0.5, 0.9), randf_range(0.4, 0.7))
