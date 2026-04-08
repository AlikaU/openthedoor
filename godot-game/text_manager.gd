extends Node

const MESSAGE_DURATION = 4.0

const NOBODY_HOME_FIRST = "Nobody is home yet..."
const NOBODY_HOME = "Nobody is home"

const FOOD_HINT = "Going out can be useful to find food."
const FOOD_LOW = "It would be good to find some food soon."
const FOOD_LEAVE = "Should go out and find food. Same way you came in."
const FOOD_URGENT = "It is urgent to find food. Should go out now."

const HINT_ARROW_KEYS = "Use arrow keys to move."
const HINT_WASD = "Use wasd to move."

const GAME_OVER = "Game over. %s died of starvation."

var message_label: Label
var message_timer: float = 0.0
var message_queue: Array = []

func _process(delta: float) -> void:
	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0:
			message_timer = 0.0
			if message_queue.is_empty():
				_clear()
			else:
				_show_next()

func push(text: String, priority: bool = false) -> void:
	if priority:
		message_timer = 0.0
		message_queue.push_front(text)
	else:
		message_queue.append(text)
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
	_display(message_queue.pop_front())

func _display(text: String) -> void:
	if message_label:
		message_label.text = text
	message_timer = MESSAGE_DURATION

func _clear() -> void:
	if message_label:
		message_label.text = ""
