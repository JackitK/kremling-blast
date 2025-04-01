extends Node2D
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var baddy_left_label: Label = %baddy_left_label

@export var baddy_count_max: int = 10
var baddy_left_count: int = 10
signal shot_interaction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_progress_bar()
	Events.enemy_hit.connect(enemy_shot_event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func enemy_shot_event(value: int) -> void:
	if value == null:
		value = 1
	baddy_left_count -= value
	update_progress_bar()

func set_progress_bar() -> void:
	baddy_left_count = baddy_count_max
	baddy_left_label.text = "Baddies Bonked: " + str(baddy_count_max - baddy_left_count) + "/" + str(baddy_count_max)
	progress_bar.max_value = baddy_count_max
	progress_bar.value = baddy_left_count
	
	
func update_progress_bar() -> void:
	if baddy_left_count <= 0:
		baddy_left_count = 0
		baddy_left_label.text = "Level complete"
		Events.emit_level_cleared()
	else:
		baddy_left_label.text = "Baddies Bonked: " + str(baddy_count_max - baddy_left_count) + "/" + str(baddy_count_max)
	progress_bar.value = baddy_left_count
