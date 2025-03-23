extends Area2D
var banana_speed: float = 6.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movement_input()


func _on_body_entered(body: Node2D) -> void:
	print ("banana collision")
	if body.is_in_group("good_guys"):
		banana_collected()
	
func banana_collected() -> void:
	Events.emit_banana_tally(1)
	queue_free()

func movement_input() -> void:
	if Events.enable_banana_movement == false:
		pass
	else:
		if Input.is_action_pressed("move_left"):
			position.x -= banana_speed
		if Input.is_action_pressed("move_right"):
			position.x += banana_speed
		if Input.is_action_pressed("move_up"):
			position.y -= banana_speed
		if Input.is_action_pressed("move_down"):
			position.y += banana_speed
