class_name  Baddy
extends CharacterBody2D
signal shot
signal enemy_hit
@onready var hit_area: Area2D = $shoot_area
@onready var change_direction_timer: Timer = $change_direction_timer
@onready var baddy_sound: AudioStreamPlayer2D = $baddy_sound

@export var speed: float = 200.0
@export var max_speed: float = 800.0
@export var hit_speed: float = 20.0
@export var shot_value: int = 1
var dir_x : float = 1
var dir_y : float = 1
var motion = Vector2(0,0)
var mouse_inside = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.shot_triggered.connect(check_for_hit)
	#hit_area.shot.connect(shot_event)
	motion = Vector2(speed,speed)
	velocity = Vector2(speed,speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	enemy_movement()

func check_for_hit():
	if mouse_inside == true:
		shot_event()

func shot_event():
	randomly_change_direction()
	if speed + hit_speed >= max_speed:
		speed = max_speed
	else:
		speed += hit_speed
	print(velocity)
	print("I'm hit!")
	baddy_sound.play()
	Events.emit_enemy_hit(shot_value)

func enemy_movement():
	if is_on_wall() or is_on_floor() or is_on_ceiling():
		dir_x *= -1
		dir_y *= -1
	velocity.x = speed * dir_x
	velocity.y = speed * dir_y
	move_and_slide()


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
	print("mouse in enemy")

func _on_shoot_area_mouse_exited() -> void:
	mouse_inside = false
	print("mouse leave enemy")
