class_name  Baddy
extends CharacterBody2D
signal shot
signal enemy_hit
signal remote_sound_call(sound:String)
signal egged_event(fling_state:bool)
signal in_no_shoot_zone(state:bool)

@onready var sprite: AnimatedSprite2D = $sprite
@onready var hit_area: Area2D = $shoot_area
@onready var change_direction_timer: Timer = %change_direction_timer
@onready var stun_timer: Timer = %stun_timer
@onready var baddy_sound: AudioStreamPlayer2D = %baddy_sound

@onready var speed:float = 200.0

@onready var shoot_area: Area2D = $shoot_area
@onready var nearby_dector: Area2D = $nearby_dector
var shootable: bool = true

@export var base_speed: float = 200.0
@export var max_speed: float = 800.0
@export var hit_speed: float = 20.0
@export var shot_value: int = 1
@export var score_value: int = 1
@export var scary:bool = false
@export_enum("default", "light", "heavy") var weight: String = "default"
@export_enum("none", "golden", "pirate") var special_trait: String = "none"
@export var start_still: bool = false
var temp_speed: float = 200.0

var dir_x : float = 1
var dir_y : float = 1
var motion = Vector2(0,0)
var start_position: Vector2 = Vector2(500,500)
var stunned:bool = false
var base_scale: Vector2 = Vector2 (1.0, 1.0)
var mouse_inside: bool = false
@export var is_default_foe: bool = false
@export var has_gold_state: bool = false
@export var ignore_mobile_size_boost: bool = false
@onready var animation_player: AnimationPlayer = %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_sprite_to_child_sprite()
	Events.shot_triggered.connect(check_for_hit)
	remote_sound_call.connect(sound_from_string)
	in_no_shoot_zone.connect(check_if_in_shoot_zone)
	Events.stop_sounds.connect(stop_all_sounds)
	diff_adjustments()
	mobile_adjustments()
	if start_still:
		speed = 0
	else:
		speed = base_speed
	if start_still == false:
		motion = Vector2(speed,speed)
		velocity = Vector2(speed,speed)
	start_position = global_position
	if special_trait == "golden":
		implement_gold_mode()
	if special_trait == "pirate":
		sprite.set_animation("pirate")

func set_sprite_to_child_sprite() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	enemy_movement()

func check_for_hit():
	if mouse_inside == true and shootable == true:
		shot_event()

func shot_event():
	if start_still == true and speed == 0:
		if base_speed > 0:
			speed = base_speed
		else:
			speed = 30
		enemy_movement()
		# Disable hit_speed on easy mode after shot
		if SettingsDataContainer.difficulty == 0:
			hit_speed = 0
	elif speed + hit_speed >= max_speed:
		speed = max_speed
	else:
		speed += hit_speed
	baddy_sound.play()
	Events.emit_enemy_hit(shot_value)
	Events.emit_score_tally(score_value)
	#For score specifically earned by shooting (used for spawners not the actual score value)
	if shot_value == 0: 
		# If statement for the excpetion an enemy doesn't give a hit value (like a mook in a boss fight)
		# In this case set the value to 1 so spawners still spawn when shooting things
		Events.emit_click_score_tally(1) 
	else:
		Events.emit_click_score_tally(score_value) 
	if not stunned:
		randomly_change_direction()

func enemy_movement():
	if is_on_wall() or is_on_floor() or is_on_ceiling():
		dir_x *= -1
		dir_y *= -1
	velocity.x = speed * dir_x
	velocity.y = speed * dir_y
	if speed != 0:
		move_and_slide()


func _on_change_direction_timer_timeout() -> void:
	randomly_change_direction()
	var new_time = randi_range(0.5,2.5)
	change_direction_timer.start(new_time)

func randomly_change_direction() -> void:
	if stunned or (start_still and speed == 0):
		return
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

func _on_nearby_dector_area_entered(area: Area2D) -> void:
	if area.is_in_group("breakable_block"):
		var block = area.get_parent()
		if block is BreakableBlock:
			block.collide_event.emit(weight)
			
#Play a sound effect, based on a string cue
func sound_from_string(prompt:String) -> void:
	match prompt:
		"hurt":
			baddy_sound.play()
		_:
			pass

func stunned_event() -> void:
	if stunned == false:
		temp_speed = speed
		speed = 0
		baddy_sound.play()
		stun_timer.start()
	else:
		if speed > 0:
			speed = 0
		var t_left = stun_timer.time_left
		t_left += 1
		stun_timer.start(t_left)


func _on_stun_timer_timeout() -> void:
	stunned = false
	if temp_speed > speed:
		speed = temp_speed
	var new_time = randi_range(0.5,2.5)
	change_direction_timer.start(new_time)

#Makes object unclickable.
func hide_shoot_colision() -> void:
	shoot_area.set_deferred("monitorable", false)
	shootable = false
	
#Makes an unclickable object able to be clicked again.
func reveal_shoot_colision() -> void:
	shoot_area.set_deferred("monitorable", true)
	shootable = true

#Makes it so Kongs and enemies don't trigger events tide to colliding with this enemy. 
#Object still bonuces off physical objects.
func hide_interaction_with_objects() -> void:
	nearby_dector.set_deferred("monitorable", false)
	
#Reinable events tied to colliding with Kongs and enemies
func reveal_interaction_with_objects() -> void:
	nearby_dector.set_deferred("monitorable", true)

func implement_gold_mode() -> void:
	#If "golden exists as an animation for the sprite, then make golden
	if has_gold_state:
		sprite.set_deferred("animation", "gold")
	if sprite.get_animation() == null:
		sprite.set_animation("default")
	if sprite.animation == null:
		sprite.animation = "default"
	if score_value == 1:
		score_value = 3
	else:
		score_value *= 2

func get_egged(egg:Egg) -> void:
	pass
	
#Currently only works with enemies that don't change shoot colision through other means
func check_if_in_shoot_zone(state:bool) -> void:
	if state == true:
		hide_shoot_colision()
	else:
		reveal_shoot_colision()

func diff_adjustments() -> void:
	match SettingsDataContainer.difficulty:
			0: #Easy
				base_speed *= .8
				max_speed *= .8
				if start_still == false:
					hit_speed = 0
			1: #Normal
				pass
			2: #Hard
				base_speed *= 1.2
				max_speed *= 1.2

func mobile_adjustments() -> void:
	if OS.has_feature("mobile") || DisplayServer.is_touchscreen_available():
		if ignore_mobile_size_boost == false:
			base_scale *= 1.3
			scale *= 1.3

func stop_all_sounds() -> void:
	baddy_sound.stop()
	
