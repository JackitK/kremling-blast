extends Control
@onready var score_label: Label = %score_label
@onready var score_count: Label = %score_count
@onready var bonus_time_label: Label = %bonus_time_label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.hide_while_in_options.connect(tuck_while_in_options)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func tuck_while_in_options() -> void:
	if visible == true:
		visible = false
	else:
		visible = true
