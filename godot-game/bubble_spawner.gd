extends Node2D

const Bubble = preload("res://bubble.tscn")
var timer = 0.0

func _process(delta):
	timer += delta
	if timer > 1 && GameInput.door_open:
		timer = 0.0
		spawn_bubble()

func spawn_bubble():
	var bubble = Bubble.instantiate()
	bubble.position = Vector2(randf_range(370, 390), 695)
	get_parent().add_child(bubble)
