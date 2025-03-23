extends Area2D
signal shot
@onready var hurt_cry: AudioStreamPlayer2D = %hurt_cry

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input_event (viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	pass
