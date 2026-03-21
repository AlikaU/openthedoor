extends Node

signal shiny_entered
signal shiny_left
signal fluffy_entered
signal fluffy_left
signal debug_toggled

var udp = PacketPeerUDP.new()
var door_open = false
var shiny_in_the_house = false
var fluffy_in_the_house = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	udp.bind(4242)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if udp.get_available_packet_count() > 0:
		var msg = udp.get_packet().get_string_from_utf8().strip_edges()
		var data = JSON.parse_string(msg)
		if data:
			var on = data.get("on", false)
			match data.get("name", ""):
				"shiny":
					shiny_in_the_house = on
					if on: shiny_entered.emit()
					else: shiny_left.emit()
				"fluffy":
					fluffy_in_the_house = on
					if on: fluffy_entered.emit()
					else: fluffy_left.emit()
				"door":
					door_open = !on

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

	if Input.is_action_just_pressed("spawn_fluffy"):
		if fluffy_in_the_house:
			fluffy_in_the_house = false
			fluffy_left.emit()
		else:
			fluffy_in_the_house = true
			fluffy_entered.emit()

	if Input.is_action_just_pressed("toggle_debug"):
		debug_toggled.emit()

	if Input.is_action_just_pressed("ui_cancel"):  # Escape key
		get_tree().quit()
