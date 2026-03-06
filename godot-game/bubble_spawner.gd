extends Node2D

const Bubble = preload("res://bubble.tscn")
var timer = 0.0

func _process(delta):
	timer += delta
	if timer > 0.2 && DoorInput.door_open:
		timer = 0.0
		spawn_bubble()

func spawn_bubble():
	var bubble = Bubble.instantiate()
	bubble.position = Vector2(-200, randf_range(600, 1200))  # random height on left edge
	get_parent().add_child(bubble)
