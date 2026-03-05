extends Node

var udp = PacketPeerUDP.new()
var door_open = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	udp.bind(4242)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if udp.get_available_packet_count() > 0:
		var msg = udp.get_packet().get_string_from_utf8().strip_edges()
		door_open = "ON -> OFF" in msg
	
	# keyboard fallback
	if Input.is_action_pressed("ui_accept"):
		door_open = false
	elif Input.is_action_just_released("ui_accept"):
		door_open = true
		
	if Input.is_action_just_pressed("ui_cancel"):  # Escape key
		get_tree().quit()
