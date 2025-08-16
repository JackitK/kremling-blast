class_name Bristle
extends Baddy

@onready var roll_timer: Timer = %roll_timer
#@onready var sprite: AnimatedSprite2D = %bristle_sprite

var rolling_state: bool = false
signal collide_event(target_label: String)
static var max_penality: int = 30
static var current_penality: int = 0
@export var collide_penality: int = 5
var ingore_max_penality = false


func _ready() -> void:
	stop_rolling()
	super()
	collide_event.connect(bristle_bump)
	
func set_sprite_to_child_sprite() -> void:
	sprite = %bristle_sprite
	
func enemy_movement():
	if rolling_state == false:
		return
	else:
		super()
	
func shot_event():
	if rolling_state == false:
		baddy_sound.play()
		Events.emit_enemy_hit(shot_value)
		Events.emit_score_tally(score_value)
		rolling_state = true
		start_rolling()
		if current_penality >= collide_penality:
			current_penality -= collide_penality
			print("hit penality: " + str(current_penality))
	else:
		reverse_direction()
		
func _on_change_direction_timer_timeout() -> void:
	if stunned:
		return
	randomly_change_direction()
	var new_time = randi_range(1.0,3.5)
	change_direction_timer.start(new_time)
		
# Function that plays when a Bristle object collides with another object
func bristle_bump(target:String) -> void:
	if rolling_state == false:
		print("not rolling, skip")
		return
	else:
		print("bristle bump called")
		match target:
			"kong":
				if ingore_max_penality:
					Events.emit_score_tally(-collide_penality)
					print ("no max penality, take points")
					return
				if current_penality + collide_penality <= max_penality:
					Events.emit_score_tally(-collide_penality)
					current_penality += collide_penality
				else:
					return
		

func _on_roll_timer_timeout() -> void:
	state_swap()
		
func state_swap() -> void:
	if rolling_state == true:
		stop_rolling()
	else:
		start_rolling()
		
	var ran_timer: float = randi_range(2,6)
	roll_timer.start(ran_timer)

func start_rolling() -> void:
	rolling_state = true
	sprite.animation = "rolling"
	speed = max_speed
	scary = true
	enemy_movement()

func stop_rolling() -> void:
	rolling_state = false
	sprite.animation = "default"
	speed = base_speed
	scary = false
	
func reverse_direction() -> void:
	dir_x *= -1
	dir_y *= -1
