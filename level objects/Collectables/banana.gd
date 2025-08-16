class_name Banana
extends CharacterBody2D
var banana_speed: float = 80

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var start_position: Vector2 = Vector2(500,500)
	start_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movement_input()


func _on_body_entered(body: Node2D) -> void:
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
			velocity.x = -banana_speed
		elif Input.is_action_pressed("move_right"):
			velocity.x = banana_speed
		else:
			velocity.x = 0
		if Input.is_action_pressed("move_up"):
			velocity.y = -banana_speed
		elif Input.is_action_pressed("move_down"):
			velocity.y = banana_speed
		else:
			velocity.y = 0
			
		move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("good_guys"):
		banana_collected()
