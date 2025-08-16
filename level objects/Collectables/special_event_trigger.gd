extends Area2D

@export_enum("none", "make gold") var events: String = "none"
@export_enum("one_by_one", "only_once", "all") var range: String = "all"
@export_enum("shots", "time", "score") var spawn_by: String = "shots"
@onready var event_timer: Timer = $event_timer
@export var trigger_value:int = 10
var tick_count:int = 0
var event_done:bool = false
var base_level

func _ready() -> void:
	base_level = get_parent().get_parent()
	if spawn_by == "shots":
		Events.click_score_tally.connect(tick_up_countdown)
	elif spawn_by == "score":
		Events.score_tally.connect(tick_up_countdown)
	elif spawn_by == "time":
		event_timer.wait_time = trigger_value
		event_timer.start()
		
	
	if base_level is Level:
		print("parent set")
	else:
		base_level = null
			
func tick_up_countdown(tally: int) -> void:
	tick_count += tally
	if tick_count >= trigger_value:
		trigger_event()
		tick_count = 0


func _on_spawn_timer_timeout() -> void:
	trigger_event()
	event_timer.start()
	

func trigger_event() -> void:
	if event_done:
		print ("The event is finished, don't run anymore instances")
		return
	print("trigger a special event")
	match events:
		"make gold":
			print("make them gold")
			set_golden_Kritter_morph()
	if range == "only_once":
		event_done = true
		

func set_golden_Kritter_morph():
	var bad_guys = get_tree().get_nodes_in_group("baddies")
	# Use the batch of bad guys to sort out Kritters and set each of them to their golden varient
	for i in bad_guys:
		if i is Baddy:
			print("baddy found")
			if i.has_gold_state and i.special_trait != "golden":
				print("trigger it's gold mode")
				i.special_trait = "golden"
				i.implement_gold_mode()
				if range.contains("all"):
					print("continue check")
				if range.contains("one_by_one")  || range.contains("only_once"):
					print("stop check")
					return
