extends Node2D

@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(
	Color.from_hsv(0.65, 0.8, 0.15)  # blue hue, vivid-ish, very dark value
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "door open: " + str(DoorInput.door_open)
