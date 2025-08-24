class_name CaptainKrow
extends Boss
@onready var fly_timer: Timer = %fly_timer


func _ready() -> void:
	super()
	egged_event.connect(get_egged)

func shot_event():
	if sprite.animation == "in_air":
		return
	else:
		super()

func check_for_damaged_events() -> void:
	super()
	
func _on_change_direction_timer_timeout() -> void:
	if stunned:
		return
	randomly_change_direction()
	var new_time = randi_range(0.5,2.5)
	change_direction_timer.start(new_time)

func half_health_event() -> void:
	sprite.animation = "in_air"
	var spawner_group = get_tree().get_nodes_in_group("spawner")
	for node in spawner_group:
		if node is Spawner:
			node.spawing_active = true
	var mook_group = get_tree().get_nodes_in_group("followers")
	var move_target_to = global_position
	for node in mook_group:
		node.set("global_position", move_target_to)
	
func low_health_event() -> void:
	sprite.animation = "in_air"
	
	power_sound.play()
	speed *= 1.5
	max_speed *=1.5
	
	var monkey_group = get_tree().get_nodes_in_group("good_guys")
	var move_target_to = global_position
	for node in monkey_group:
		if node is Kong:
			if node is not DonkeyKong || node is not DiddyKong:
				node.set("global_position", move_target_to)
				node.set("start_position", move_target_to)
	
func get_egged(egg:Egg) -> void:
	if egg.fling_state == true:
		print("GET EGGED!")
		baddy_sound.play()
		if sprite.animation != "default" and boss_flags["low_health"] == false:
			sprite.animation = "default"
			animation_player.play("egged")
		else:
			animation_player.play("hit")
		Events.emit_enemy_hit(shot_value)
		Events.emit_score_tally(egg.score_value)
		#For score specifically earned by shooting (used for spawners not the actual score value)
		Events.emit_click_score_tally(score_value) 
		if health_remain > 0:
			health_remain -= 1
		if score_losted > 0:
			score_losted -= score_value
		check_for_damaged_events()
		egg.sprite.animation = "splat"
