extends Node2D

const Shiny = preload("res://shiny.tscn")
const Fluffy = preload("res://fluffy.tscn")

var blob_instances = {"shiny": null, "fluffy": null}
var blob_scenes = {}

@onready var debugLabel = $CanvasLayer/DebugLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blob_scenes = {"shiny": Shiny, "fluffy": Fluffy}
	GameInput.shiny_entered.connect(_on_shiny_entered)
	GameInput.shiny_left.connect(_on_shiny_left)
	GameInput.fluffy_entered.connect(_on_fluffy_entered)
	GameInput.fluffy_left.connect(_on_fluffy_left)
	GameInput.debug_toggled.connect(_on_debug_toggled)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if debugLabel.visible:
		var bubbles = str(blob_instances["shiny"].numBubblesEaten) if blob_instances["shiny"] else "—"
		debugLabel.text = "door: %s\nshiny: %s\nfluffy: %s\nbubbles: %s" % [
			GameInput.door_open, GameInput.shiny_in_the_house,
			GameInput.fluffy_in_the_house, bubbles
		]


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
	# kill any dying blob that's still in the tree
	var existing = get_node_or_null("dying_blob_" + id)
	if existing:
		existing.queue_free()
	var blob = blob_scenes[id].instantiate()
	blob.position = $SpawnPoint.position
	add_child(blob)
	blob_instances[id] = blob

func despawn_blob(id):
	var dying = blob_instances[id]
	blob_instances[id] = null
	dying.name = "dying_blob_" + id  # rename so we can find it later
	dying.vanish()
