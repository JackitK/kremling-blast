class_name Spawner
extends Area2D

var default_path = preload("res://level objects/Collectables/banana.tscn")
@export var import_path:String = ""
var path
@export var spawn_value:int = 10
var tick_count:int = 0
var spawn_count:int = 0
@export var spawn_max:int = 64
@export var movement_amount:float = 30
@export var spawing_active:bool = true
@export_enum("shots", "time", "score") var spawn_by: String = "shots"
@export_enum("banana", "baddy", "ally") var spawner_type: String = "banana"
@export var is_endless_mode:bool = false
@export_enum("still", "shift_right", "shift_down") var movement_type: String = "still"
@export var spawn_scale: float = 1 #transforms object size based on value
@onready var spawn_timer: Timer = $spawn_timer
var start_position: Vector2 = Vector2(500,500)

func _ready() -> void:
	
	if import_path == "":
		path = default_path
	else:
		path = load(import_path)
	
	if spawn_by == "shots":
		Events.click_score_tally.connect(tick_up_countdown)
	elif spawn_by == "score":
		Events.score_tally.connect(tick_up_countdown)
	elif spawn_by == "time":
		spawn_timer.wait_time = spawn_value
		spawn_timer.start()
		
	var base_level = get_parent().get_parent()
	if base_level is Level:
		print("parent set")
	else:
		base_level = null
		
	start_position = global_position

#Attempt to get banana to spawn in level. 
#Currently banana doesn't visible show up, so I've abon
func spawn_object() -> void:
	if spawing_active == false:
		return
	elif has_overlapping_areas() and spawner_type != "banana":
		print("There is an object blocking the spawner")
		return
	
	if spawn_count < spawn_max || spawn_max == 0:
		spawn_count += 1
		var new_obj = path.instantiate()
		#new_obj.global_position = global_position
		new_obj.set("global_position", global_position)
		new_obj.set("global_scale", Vector2(spawn_scale, spawn_scale))
	
		if is_endless_mode == true:
			run_endless_related_checks(new_obj)
		get_parent().call_deferred("add_child",new_obj)
		
		handle_spawner_movement()

func run_endless_related_checks(object) -> void:
	Events.emit_current_score_update
	if object is Bristle:
		print("update Bristle from spawner")
		Events.emit_current_score_update()
		#Find a way to assure this doesn't get set until after score is fully updated.
		var current_score = Events.send_score()
		spawn_value += 100
		if object.max_penality > current_score:
			object.max_penality = current_score
		#object.ingore_max_penality = true
		

func tick_up_countdown(tally: int) -> void:
	tick_count += tally
	if tick_count >= spawn_value:
		tick_count = 0
		spawn_object()


func _on_spawn_timer_timeout() -> void:
	spawn_object()
	spawn_timer.start()

func handle_spawner_movement() -> void:
	match movement_type:
			"shift_right":
				position.x += movement_amount
				
			"shift_down":
				position.y += movement_amount
			_:
				pass
