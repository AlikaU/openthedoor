extends Node

var food: int = 20
var food_timer: float = 0.0
var message_timer: float = 0.0
var game_over: bool = false
var tint_overlay: ColorRect

const FOOD_DEPLETION_INTERVAL = 1.0
const MESSAGE_DURATION = 4.0
const EARLY_WARNING_THRESHOLD = 20
const URGENT_THRESHOLD = 10
const FOOD_TYPES = ["apples", "carrots", "eggs", "potatoes", "bananas", "tomatoes"]
const ARRIVE_VERBS = ["came home with", "scavenged", "found", "returned with", "brought"]

@onready var foodLabel = $"/root/World/CanvasLayer2/FoodLabel"
@onready var messageLabel = $"/root/World/CanvasLayer2/MessageLabel"

func _ready() -> void:
	GameInput.shiny_entered.connect(_on_shiny_entered)
	GameInput.fluffy_entered.connect(_on_fluffy_entered)
	_setup_tint_overlay()
	_update_food_label()

func _setup_tint_overlay() -> void:
	tint_overlay = ColorRect.new()
	tint_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	tint_overlay.color = Color(0.5, 0.0, 0.35, 0.0)
	tint_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var canvas = $"/root/World/CanvasLayer2"
	canvas.add_child(tint_overlay)
	canvas.move_child(tint_overlay, 0)

func _process(delta: float) -> void:
	if game_over:
		return

	var someone_home = GameInput.shiny_in_the_house or GameInput.fluffy_in_the_house

	if someone_home:
		food_timer += delta
		if food_timer >= FOOD_DEPLETION_INTERVAL:
			food_timer -= FOOD_DEPLETION_INTERVAL
			food -= 1
			_update_food_label()
			_update_tint()
			if food <= 0:
				food = 0
				_trigger_game_over()
				return

	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0:
			message_timer = 0
			_update_message()
	else:
		_update_message()

func _update_tint() -> void:
	var alpha: float = 0.0
	if food <= URGENT_THRESHOLD:
		alpha = lerp(0.15, 0.5, float(URGENT_THRESHOLD - food) / float(URGENT_THRESHOLD))
	elif food < EARLY_WARNING_THRESHOLD:
		alpha = lerp(0.0, 0.15, float(EARLY_WARNING_THRESHOLD - food) / float(EARLY_WARNING_THRESHOLD - URGENT_THRESHOLD))
	tint_overlay.color.a = alpha

func _on_shiny_entered() -> void:
	_character_arrived("shiny")

func _on_fluffy_entered() -> void:
	_character_arrived("fluffy")

func _character_arrived(who: String) -> void:
	var amount = randi_range(8, 13)
	var food_type = FOOD_TYPES[randi() % FOOD_TYPES.size()]
	var verb = ARRIVE_VERBS[randi() % ARRIVE_VERBS.size()]
	food += amount
	_update_food_label()
	_update_tint()
	messageLabel.text = "%s %s %d %s." % [who, verb, amount, food_type]
	message_timer = MESSAGE_DURATION

func _update_food_label() -> void:
	foodLabel.text = "food: %d" % food

func _update_message() -> void:
	var someone_home = GameInput.shiny_in_the_house or GameInput.fluffy_in_the_house
	if not someone_home:
		messageLabel.text = ""
	elif food < URGENT_THRESHOLD:
		messageLabel.text = "go out now! leave the same way you came in."
	elif food < EARLY_WARNING_THRESHOLD:
		messageLabel.text = "food is running low. go outside soon."
	else:
		messageLabel.text = ""

func _trigger_game_over() -> void:
	game_over = true
	var victim = "fluffy" if GameInput.fluffy_in_the_house else "shiny"
	messageLabel.text = "game over. %s died of starvation." % victim
