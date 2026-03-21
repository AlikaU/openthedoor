extends Node

signal shiny_entered
signal shiny_left

var udp = PacketPeerUDP.new()
var door_open = false
var shiny_in_the_house = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	udp.bind(4242)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if udp.get_available_packet_count() > 0:
		var msg = udp.get_packet().get_string_from_utf8().strip_edges()
		if "4: ON -> OFF" in msg:
			door_open = true
		if "4: OFF -> ON" in msg:
			door_open = false
		if "2: ON -> OFF" in msg:
			shiny_in_the_house = false
			shiny_left.emit()
		if "2: OFF -> ON" in msg:
			shiny_in_the_house = true
			shiny_entered.emit()

	# keyboard fallback
	if Input.is_action_pressed("ui_accept"):
		door_open = false
	elif Input.is_action_just_released("ui_accept"):
		door_open = true

	if Input.is_action_just_pressed("spawn_shiny"):
		if shiny_in_the_house:
			shiny_in_the_house = false
			shiny_left.emit()
		else:
			shiny_in_the_house = true
			shiny_entered.emit()

	if Input.is_action_just_pressed("ui_cancel"):  # Escape key
		get_tree().quit()
