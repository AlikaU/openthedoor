extends Node2D

const Shiny = preload("res://player/shiny.tscn")
const Fluffy = preload("res://player/fluffy.tscn")

var blob_instances = {"shiny": null, "fluffy": null}
var blob_scenes = {}

@onready var debugLabel = $CanvasLayer/DebugLabel

func _ready() -> void:
	blob_scenes = {"shiny": Shiny, "fluffy": Fluffy}
	GameInput.shiny_entered.connect(_on_shiny_entered)
	GameInput.shiny_left.connect(_on_shiny_left)
	GameInput.fluffy_entered.connect(_on_fluffy_entered)
	GameInput.fluffy_left.connect(_on_fluffy_left)
	GameInput.debug_toggled.connect(_on_debug_toggled)

func _process(delta: float) -> void:
	if debugLabel.visible:
		var door_status = "open" if GameInput.door_open else "closed"
		debugLabel.text = "door: %s" % door_status

func _on_debug_toggled():
	debugLabel.visible = !debugLabel.visible

func _on_shiny_entered():
	spawn_blob("shiny")

func _on_shiny_left():
	despawn_blob("shiny")

func _on_fluffy_entered():
	spawn_blob("fluffy")

func _on_fluffy_left():
	despawn_blob("fluffy")

func toggle_blob(id):
	if blob_instances[id] != null:
		despawn_blob(id)
	else:
		spawn_blob(id)

func spawn_blob(id):
	if blob_instances[id] != null:
		return
	var existing = get_node_or_null("dying_blob_" + id)
	if existing:
		existing.queue_free()
	var blob = blob_scenes[id].instantiate()
	blob.position = $SpawnPoint.position
	add_child(blob)
	blob_instances[id] = blob

func despawn_blob(id):
	if blob_instances[id] == null:
		return
	var dying = blob_instances[id]
	blob_instances[id] = null
	dying.name = "dying_blob_" + id
	dying.vanish()
