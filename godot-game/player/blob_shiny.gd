extends "res://player/blob_base.gd"

@export var inv: Inv

func _ready():
	super()
	action_left = "shiny_left"
	action_right = "shiny_right"
	action_up = "shiny_up"
	action_down = "shiny_down"
