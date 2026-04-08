extends Node2D

const Plastic = preload("res://plastic.tscn")

var timer = 0.0

func _process(delta):
	timer += delta
	if timer > 1 && GameInput.door_open:
		timer = 0.0
		_spawn_trash()

func _spawn_trash():
	var trash = Plastic.instantiate()
	trash.position = Vector2(randf_range(340, 370), 715)
	get_parent().add_child(trash)
