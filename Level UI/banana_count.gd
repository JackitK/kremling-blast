extends Node2D
var banana_count: int = 0
@onready var banana_count_label: Label = %banana_count_label
const MAX_BANANAS: int = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.banana_tally.connect(update_tally)

func update_tally(value: int) -> void:
	print("updating banana count")
	#if we are taking away bananas, assure there is enough banana to take away
	if value < 0 and banana_count >= value:
		banana_count += value
	#If we are adding bananas, then increase the count (Assuming its not above the max)
	if value > 0 and banana_count < MAX_BANANAS:
		banana_count += value
	banana_count_label.text = str(banana_count)
	
func get_banana_count() -> int:
	return banana_count
