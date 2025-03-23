extends Level
class_name Bonus_Level

@export var starting_bonus_time: int = 15
@onready var bonus_time_left: int = 15
@onready var level_time_label: Label = %level_time_label
@onready var second_ticker: Timer = %second_ticker
@onready var bonus_message_container: Control = %Bonus_message_container

@onready var bonus_message_box: TextureRect = %bonus_message_box
@onready var intro_timer: Timer = $timers/intro_timer

func _ready() -> void:
	super()
	remove_baddy_left_meter()
	bonus_stage_intro()
	bonus_time_left = starting_bonus_time
	level_time_label.text = str(bonus_time_left)
	second_ticker.start()

func bonus_stage_intro():
	bonus_message_container.visible = true
	get_tree().paused = true
	intro_timer.start()

func hurt_friend_event(value:int):
	bonus_level_fail()

func remove_baddy_left_meter() -> void:
	baddy_left_meter.queue_free()
	miss_counter.queue_free()

func process_and_display_countdown() -> void:
	bonus_time_left -= 1
	if bonus_time_left > 0:
		level_time_label.text = str(bonus_time_left)
	else:
		level_time_label.text = "0"
		end_of_bonus_level()

func end_of_bonus_level() -> void:
	pop_up_message.visible = true
	get_tree().paused = true
	pop_up_message.text = "Time Up!"
	level_track.stop()
	victory_theme.play()

func bonus_level_fail() -> void:
	pop_up_message.visible = true
	get_tree().paused = true
	pop_up_message.text = "You Failed"
	victory_theme.stream = load("res://sounds/sound effects/bonus_miss.wav")
	level_track.stop()
	victory_theme.play()

func _on_second_ticker_timeout() -> void:
	process_and_display_countdown()
	if bonus_time_left > 0:
		second_ticker.start()


func _on_intro_timer_timeout() -> void:
	get_tree().paused = false
	bonus_message_container.visible = false
