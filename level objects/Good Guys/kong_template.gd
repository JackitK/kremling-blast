class_name Kong
extends CharacterBody2D

signal shot
signal remote_sound_call(sound:String)
signal egged_event(fling_state:bool)
signal in_no_shoot_zone(state:bool)

@onready var hit_area: Area2D = $shoot_area
@onready var change_direction_timer: Timer = $timers/change_direction_timer
@onready var panic_timer: Timer = $timers/panic_timer
@onready var hurt_cry: AudioStreamPlayer2D = %hurt_cry
@onready var power_up: AudioStreamPlayer2D = %power_up
@onready var scared_sound: AudioStreamPlayer2D = %scared
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var shoot_area: Area2D = $shoot_area


@export var base_speed: float = 200.0
@export var max_speed: float = 800.0
@export var hit_speed: float = 20.0
@export var shot_value: int = 1
@export var max_points_earned: int = 50
@export var fearful: bool = false
@export_enum("default", "light", "heavy") var weight: String = "default"
@export var start_still: bool = false
@export var is_default_kong:bool = false

var dir_x : float = 1
var dir_y : float = 1
var motion = Vector2(0,0)
var speed: float = base_speed
var start_position: Vector2 = Vector2(500,500)
var base_scale: Vector2 = Vector2 (1.0, 1.0)

var mouse_inside: bool = false
var invulnerable: bool = false
var panicking: bool = false
var stunned: bool = false
var shrunk_state: bool = false
static var panick_sound_playing = false
var points_earned:int = 0
var shootable: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.shot_triggered.connect(check_for_hit)
	Events.power_up.connect(check_for_power_up)
	remote_sound_call.connect(sound_from_string)
	in_no_shoot_zone.connect(check_if_in_shoot_zone)
	diff_adjustments()
	if start_still:
		speed = 0
	else:
		speed = base_speed
	motion = Vector2(speed,speed)
	velocity = Vector2(speed,speed)
	base_scale = scale
	start_position = global_position
	egged_event.connect(get_egged)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	kong_movement()

func check_for_hit():
	if mouse_inside == true and shootable == true:
		shot_event()
	elif mouse_inside == true and shootable == false:
		pass
func check_for_power_up():
	if mouse_inside == true:
		kong_power()
	else:
		if SettingsDataContainer.simplify_kong_rate == true:
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
	hurt_cry.play()
	trigger_hurt_animation()
	Events.emit_ally_hit(shot_value)
func kong_power():
	pass
		
func kong_movement():
	if base_speed == 0:
		pass
	
	if is_on_wall() or is_on_floor() or is_on_ceiling():
		dir_x *= -1
		dir_y *= -1
		
	velocity.x = speed * dir_x
	velocity.y = speed * dir_y
	move_and_slide()

func bad_guy_collide_event(area):
	var object = area.get_parent()
	if object is Baddy:
		if object.scary == true and fearful == true:
			panic_event()
			#Ghost Kritter specific actions:
			if object is GhostKritter:
				if object.hiding == true:
					object.got_bumped.emit()
			#--- end of ghost kritter actions
	if object is Bristle:
		if object.rolling_state == true:
			hurt_cry.play()
			object.collide_event.emit("kong")
	if object is Krow:
		return
	
func good_guy_collide_event(area):
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

func _on_shoot_area_mouse_exited() -> void:
	mouse_inside = false

#Makes object unclickable.
func hide_shoot_colision() -> void:
	shoot_area.set_deferred("monitorable", false)
	shootable = false
	
#Makes an unclickable object able to be clicked again.
func reveal_shoot_colision() -> void:
	shoot_area.set_deferred("monitorable", true)
	shootable = true

#Play a sound effect, based on a string cue
func sound_from_string(prompt:String) -> void:
	match prompt:
		"hurt":
			hurt_cry.play()
		"good":
			power_up.play()
		"scared":
			if panick_sound_playing == false:
				panick_sound_playing = true
				scared_sound.play()
				await scared_sound.finished
				panick_sound_playing = false
				
		_:
			pass

func _on_nearby_detector_area_entered(area: Area2D) -> void:
	var obj = area.get_parent()
	if obj.is_in_group("baddies"):
		bad_guy_collide_event(area)
	if obj.is_in_group("good_guys"):
		good_guy_collide_event(area)
	if area.is_in_group("breakable_block"):
		var block = area.get_parent()
		if block is BreakableBlock:
			block.collide_event.emit(weight)

func panic_event() -> void:
	if invulnerable:
		return
	randomly_change_direction()
	if not panicking:
		panicking = true
		if speed == 0 and not stunned:
			base_speed = hit_speed * 2
			speed = max_speed
		else:
			speed = speed * 3
		panic_timer.start()
		sound_from_string("scared")

func _on_panic_timer_timeout() -> void:
	speed = base_speed
	panicking = false
	
func trigger_hurt_animation() -> void:
	animation_player.play("hit")
	
func get_egged(egg:Egg) -> void:
	shot_event()
	animation_player.play("egged")
	egg._on_despawn_timer_timeout()

	
#Currently only works with enemies that don't change shoot colision through other means
func check_if_in_shoot_zone(state:bool) -> void:
	if state == true:
		hide_shoot_colision()
	else:
		reveal_shoot_colision()

func diff_adjustments() -> void:
	match SettingsDataContainer.difficulty:
			0: #Easy
				if start_still == false:
					hit_speed = 0
				base_speed *= .8
				max_speed *= .8
			1: #Normal
				pass
			2: #Hard
				base_speed *= 1.2
				max_speed *= 1.2
