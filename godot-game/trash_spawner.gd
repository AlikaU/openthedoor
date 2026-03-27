extends Node2D

const Plastic = preload("res://plastic.tscn")
const ElectronicPart = preload("res://electronic_part.tscn")

var trash_types = [Plastic, ElectronicPart]
var timer = 0.0

func _process(delta):
	timer += delta
	if timer > 1 && GameInput.door_open:
		timer = 0.0
		_spawn_trash()

func _spawn_trash():
	var trash = trash_types.pick_random().instantiate()
	trash.position = Vector2(randf_range(370, 390), 695)
	get_parent().add_child(trash)
