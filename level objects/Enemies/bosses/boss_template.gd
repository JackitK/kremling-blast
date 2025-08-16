class_name Boss
extends Baddy
@onready var inv_timer: Timer = %invulnerable_timer
@export var toogle_time: float = 1.0
var invulnerable:bool = false
@onready var power_sound: AudioStreamPlayer2D = $Sounds/power_up

var health_max:int = 10
var health_remain: int = 10
var boss_flags:Dictionary = {
	"half_health": false,
 	"low_health": false
	}

var score_losted:int = 0
var max_score_lost:int = 50

func _ready() -> void:
	inv_timer.wait_time = toogle_time
	inv_timer.start()
	Events.hits_to_win.connect(set_health, ConnectFlags.CONNECT_DEFERRED)
	print(boss_flags)
	super()

func set_sprite_to_child_sprite() -> void:
	pass

func set_health(value:int) -> void:
	health_max = value
	health_remain = value
	max_score_lost = value
	print("Very Gwanty health set: " + str(health_max))
	
func shot_event():
	if invulnerable == true:
		hit_while_invul_penalty()
	else:
		#If vulnerable 
		super()
		if health_remain > 0:
			health_remain -= 1
		if score_losted > 0:
			score_losted -= score_value
		check_for_damaged_events()

func _on_change_direction_timer_timeout() -> void:
	if stunned:
		return
	randomly_change_direction()
	var new_time
	match boss_flags:
		{}:
			print("blank check")
			pass
		{"half_health": true, "low_health": true}:
			new_time = randi_range(1.5,3.5)
		{"half_health": true, "low_health": false}:
			new_time = randi_range(2.0,4.0)
		_:
			new_time = randi_range(0.5,2.5)
		
	
	change_direction_timer.start(new_time)

#Check percentage of remaining health and call functions once it gets low enough...
func check_for_damaged_events() -> void:
	print("remaining health: " + str(health_remain))
	var percent: float = (float(health_remain) / float(health_max)) * 100
	print(str(health_remain) + "/" + str(health_max))
	print(str(percent) + "%")
	match boss_flags:
		{}:
			print("blank check")
			pass
		{"half_health": false, "low_health": false}:
			print("check for health")
			if percent <= 50:
				boss_flags["half_health"] = true
				half_health_event()
		{"half_health": true, "low_health": false}:
			print("check for low health")
			if percent <= 25:
				boss_flags["low_health"] = true
				low_health_event()
		_:
			print("no match found")

func hit_while_invul_penalty() -> void:
	if score_losted <= max_score_lost -2:
		Events.emit_score_tally(-2)
		score_losted += 2
	
	var percent: float = (float(health_remain) / float(health_max)) * 100
	match boss_flags:
		{}:
			pass
		{"half_health": true, "low_health": true}:
			if percent < 25:
				increase_health()
				
		{"half_health": true, "low_health": false}:
			print("check for low health")
			if percent < 50:
				increase_health()
		_:
			if percent < 120:
				increase_health()

func _on_invulnerable_timer_timeout() -> void:
	if invulnerable == false:
		invulnerable_on()
	else:
		invulnerable_off()

func invulnerable_on() -> void:
	invulnerable = true
	sprite.modulate = Color(1, 0, 0)
	#hide_shoot_colision()
	
func invulnerable_off() -> void:
	invulnerable = false
	sprite.modulate = Color(1, 1, 1)
	#reveal_shoot_colision()
	
func half_health_event() -> void:
	power_sound.play()
	speed *= 2
	max_speed *=2
	toogle_time /= 2
	inv_timer.wait_time = toogle_time
	
func low_health_event() -> void:
	power_sound.play()
	speed *= 3
	max_speed *=3
	if SettingsDataContainer.get_autofire_state() || SettingsDataContainer.get_autofire_rate() < 0.4:
		if toogle_time/2 > 1:
			toogle_time = 1
		else:
			toogle_time *= .7
	inv_timer.wait_time = toogle_time

func increase_health() -> void:
	Events.emit_enemy_hit(-1)
	health_remain += 1
