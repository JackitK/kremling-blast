extends Node2D
class_name Miss_Counter
@export var miss_count: int = 3
@onready var miss_count_label: Label = %miss_count_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.ally_hit.connect(ally_hit)
	if SettingsDataContainer.lives_type == 1:
		miss_count = Events.global_lives
		print(miss_count)
	update_miss_counter()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ally_hit(value:int) -> void:
	if value == null:
		value = 1
	miss_count -= value
	update_miss_counter()
	if miss_count <= 0:
		game_over_state()
	
	
func update_miss_counter() -> void:
	miss_count_label.text = str(miss_count)

func game_over_state():
	Events.emit_game_over()
	print ("You screwed up. Game Over")
