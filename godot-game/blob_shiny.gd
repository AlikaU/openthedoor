extends "res://blob_base.gd"

@export var inv: Inv

func _ready():
	action_left = "shiny_left"
	action_right = "shiny_right"
	action_up = "shiny_up"
	action_down = "shiny_down"
	modulate = Color(0.918, 0.62, 1.0, 1.0)  # reddish
