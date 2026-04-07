extends Node

var food: int = 35
var food_timer: float = 0.0
var message_timer: float = 0.0
var game_over: bool = false
var tint_overlay: ColorRect

var first_time_home: bool = true
var shown_food_30_warning: bool = false
var shown_shiny_hint: bool = false
var shown_fluffy_hint: bool = false

const FOOD_DEPLETION_INTERVAL = 1.0
const MESSAGE_DURATION = 5.0
const THRESHOLD_30 = 30
const THRESHOLD_20 = 20
const THRESHOLD_12 = 12
const THRESHOLD_8 = 8

const FOOD_TYPES = ["apples", "carrots", "eggs", "potatoes", "bananas", "tomatoes"]
const ARRIVE_VERBS = ["came home with", "scavenged", "found", "returned with", "brought"]

@onready var foodLabel = $"/root/World/CanvasLayer2/FoodLabel"
@onready var messageLabel = $"/root/World/CanvasLayer2/MessageLabel"

func _ready() -> void:
	GameInput.shiny_entered.connect(_on_shiny_entered)
	GameInput.fluffy_entered.connect(_on_fluffy_entered)
	_setup_overlays()
	_update_food_label()
	messageLabel.text = GameText.NOBODY_HOME_FIRST

func _setup_overlays() -> void:
	var canvas = $"/root/World/CanvasLayer2"

	tint_overlay = ColorRect.new()
	tint_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	tint_overlay.color = Color(0.4, 0.05, 0.1, 0.0)
	tint_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(tint_overlay)
	canvas.move_child(tint_overlay, 1)

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
			if food < THRESHOLD_30 and not shown_food_30_warning:
				shown_food_30_warning = true
				_show_timed(GameText.FOOD_30)
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

func _show_timed(text: String) -> void:
	messageLabel.text = text
	message_timer = MESSAGE_DURATION

func _update_tint() -> void:
	var alpha: float = 0.0
	if food <= THRESHOLD_8:
		alpha = lerp(0.35, 0.55, float(THRESHOLD_8 - food) / float(THRESHOLD_8))
	elif food < THRESHOLD_12:
		alpha = lerp(0.0, 0.35, float(THRESHOLD_12 - food) / float(THRESHOLD_12 - THRESHOLD_8))
	tint_overlay.color.a = alpha

func _on_shiny_entered() -> void:
	_character_arrived("shiny")

func _on_fluffy_entered() -> void:
	_character_arrived("fluffy")

func _character_arrived(who: String) -> void:
	first_time_home = false
	var amount = randi_range(8, 13)
	var food_type = FOOD_TYPES[randi() % FOOD_TYPES.size()]
	var verb = ARRIVE_VERBS[randi() % ARRIVE_VERBS.size()]
	food += amount
	_update_food_label()
	_update_tint()
	_show_timed("%s %s %d %s." % [who.capitalize(), verb, amount, food_type])
	if who == "shiny" and not shown_shiny_hint:
		shown_shiny_hint = true
		await get_tree().create_timer(MESSAGE_DURATION).timeout
		_show_timed(GameText.HINT_ARROW_KEYS)
	elif who == "fluffy" and not shown_fluffy_hint:
		shown_fluffy_hint = true
		await get_tree().create_timer(MESSAGE_DURATION).timeout
		_show_timed(GameText.HINT_WASD)

func _update_food_label() -> void:
	foodLabel.text = "food: %d" % food

func _update_message() -> void:
	var someone_home = GameInput.shiny_in_the_house or GameInput.fluffy_in_the_house
	if not someone_home:
		messageLabel.text = GameText.NOBODY_HOME_FIRST if first_time_home else GameText.NOBODY_HOME
		return
	if food < THRESHOLD_8:
		messageLabel.text = GameText.FOOD_8
	elif food < THRESHOLD_12:
		messageLabel.text = GameText.FOOD_12
	elif food < THRESHOLD_20:
		messageLabel.text = GameText.FOOD_20
	else:
		messageLabel.text = ""

func _trigger_game_over() -> void:
	game_over = true
	var victim = "fluffy" if GameInput.fluffy_in_the_house else "shiny"
	messageLabel.text = GameText.GAME_OVER % victim.capitalize()
