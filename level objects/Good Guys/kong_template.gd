class_name Kong
extends CharacterBody2D
signal shot
@onready var hit_area: Area2D = $shoot_area
@onready var change_direction_timer: Timer = $change_direction_timer
@onready var hurt_cry: AudioStreamPlayer2D = %hurt_cry
@onready var power_up: AudioStreamPlayer2D = %power_up



@export var speed: float = 200.0
@export var max_speed: float = 800.0
@export var hit_speed: float = 20.0
@export var shot_value: int = 1
@export var kong_type: String = "test"
var dir_x : float = 1
var dir_y : float = 1
var motion = Vector2(0,0)
var mouse_inside = false
var invulnerable = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.shot_triggered.connect(check_for_hit)
	Events.power_up.connect(check_for_power_up)
	motion = Vector2(speed,speed)
	velocity = Vector2(speed,speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	kong_movement()

func check_for_hit():
	if mouse_inside == true:
		shot_event()
func check_for_power_up():
	if mouse_inside == true:
		kong_power()
func shot_event():
	if invulnerable:
		power_up.play()
		return
	randomly_change_direction()
	if speed + hit_speed >= max_speed:
		speed = max_speed
	else:
		speed += hit_speed
		print(velocity)
		hurt_cry.play()
		Events.emit_ally_hit(shot_value)
func kong_power():
		print("Kong Power")
		if kong_type == "monkey":
			return
		else:
			match kong_type:
				"donkey":
					print("Donkey Kong Power")
				"diddy":
					print("Diddy Kong Power")
				_:
					power_up.play()
			Events.emit_banana_tally(-1)
		
func kong_movement():
	if is_on_wall() or is_on_floor() or is_on_ceiling():
		
		dir_x *= -1
		dir_y *= -1
		
	velocity.x = speed * dir_x
	velocity.y = speed * dir_y
	move_and_slide()

func bad_guy_collide_event():
	pass

func _on_change_direction_timer_timeout() -> void:
	randomly_change_direction()
	var new_time = randi_range(0.5,2.5)
	change_direction_timer.start(new_time)

func randomly_change_direction() -> void:
	var ran_dir = randi_range(1,3)
	if ran_dir > 1:
		dir_x *= -1
	elif ran_dir > 2:
		dir_x *= -1
		dir_y *= -1
	else:
		dir_y *= -1

func _on_shoot_area_mouse_entered() -> void:
	mouse_inside = true
	print("mouse enter kong")

func _on_shoot_area_mouse_exited() -> void:
	mouse_inside = false


func _on_nearby_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("baddies"):
		print("baddy enter kong")
		bad_guy_collide_event()
