extends Node2D

const Bubble = preload("res://bubble.tscn")
var timer = 0.0

func _process(delta):
	timer += delta
	if timer > 0.2 && GameInput.door_open:
		timer = 0.0
		spawn_bubble()

func spawn_bubble():
	var bubble = Bubble.instantiate()
	bubble.position = Vector2(-20, randf_range(300, 600))  # random height on left edge
	get_parent().add_child(bubble)
