extends Node

const MESSAGE_DURATION = 4.0
const HINT_DURATION = 6.0

const NOBODY_HOME_FIRST = "Nobody is home yet..."
const NOBODY_HOME = "Nobody is home"

const FOOD_HINT = "Going out can be useful to find food."
const FOOD_LOW = "It would be good to find some food soon."
const FOOD_LEAVE = "Should go out and find food. Same way you came in."
const FOOD_URGENT = "It is urgent to find food. Should go out now."

const HINT_ARROW_KEYS = "Shiny is home. Use arrow keys to move."
const HINT_WASD = "Fluffy is home. Use W A S D keys to move."

const GAME_OVER = "Game over. %s died of starvation."

var message_label: Label
var message_timer: float = 0.0
var message_queue: Array = []  # each entry: [text, duration]

func _process(delta: float) -> void:
	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0:
			message_timer = 0.0
			if message_queue.is_empty():
				_clear()
			else:
				_show_next()

func push(text: String, priority: bool = false, duration: float = MESSAGE_DURATION) -> void:
	if priority:
		message_timer = 0.0
		message_queue.push_front([text, duration])
	else:
		message_queue.append([text, duration])
	if message_timer <= 0:
		_show_next()

func show_now(text: String) -> void:
	message_queue.clear()
	message_timer = 0.0
	_display(text)

func clear_now() -> void:
	message_queue.clear()
	message_timer = 0.0
	_clear()

func _show_next() -> void:
	if message_queue.is_empty():
		return
	var entry = message_queue.pop_front()
	_display(entry[0], entry[1])

func _display(text: String, duration: float = MESSAGE_DURATION) -> void:
	if message_label:
		message_label.text = text
	message_timer = duration

func _clear() -> void:
	if message_label:
		message_label.text = ""
