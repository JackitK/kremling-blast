class_name ChunkyKong
extends Kong

var big_Chunky: bool = false
@export var base_power_time: float = 5.0
@onready var grow_timer: Timer = %grow_timer
@onready var chunky_sprite: AnimatedSprite2D = $Chunky_Sprite
@onready var chunky_animation_player: AnimationPlayer = %Chunky_animation_player

var temp_speed_storage: float = 200.0
var foe_grow_scale: float = 1.4
var chunky_grow_scale: float = 2.0

func _ready() -> void:
	animation_player = chunky_animation_player
	super()

func bad_guy_collide_event(area):
	super(area)
		
func kong_power():
	if shrunk_state == true || is_on_wall():
		return
	if big_Chunky == false:
		big_Chunky = true
		fearful = false
		if chunky_sprite.animation != "default":
			chunky_sprite.animation = "default"
		scale *= chunky_grow_scale
		grow_the_baddies()
		temp_speed_storage = speed
		speed *= .5
		grow_timer.start(base_power_time)
		Events.emit_banana_tally(-1)
		power_up.play()
	else:
		var timeleft = grow_timer.time_left
		timeleft += base_power_time
		grow_timer.start(timeleft)
		Events.emit_banana_tally(-1)
		power_up.play()
				
#Grow enemy objects
func grow_the_baddies() -> void:
	for member in get_tree().get_nodes_in_group("baddies"):
		if member is Baddy:
			if member.is_on_wall() || member.is_on_floor():
				print ("run baddy on wall exception")
				on_wall_transform_exception()
			member.scale *= foe_grow_scale
			member.temp_speed = member.speed
			member.speed *= .5
			if member.is_on_wall() || member.is_on_floor():
				print ("baddy clip wall after transforming")
				on_wall_transform_exception()

func on_wall_transform_exception() -> void:
	return

#Shrink enemy objects back to normal size
func shrink_the_baddies() -> void:
	for member in get_tree().get_nodes_in_group("baddies"):
		if member is Baddy:
			member.scale = member.base_scale
			if member.temp_speed > member.speed:
				member.speed = member.temp_speed

func _on_grow_timer_timeout() -> void:
	big_Chunky = false
	fearful = true
	var temp_pos = position
	transform /= chunky_grow_scale
	position = temp_pos
	shrink_the_baddies()
	
func panic_event() -> void:
	if invulnerable:
		return
	if not panicking:
		panicking = true
		speed = speed * 2
		panic_timer.start()
		chunky_sprite.animation = "pancking"
		scared_sound.play()

func _on_panic_timer_timeout() -> void:
	chunky_sprite.animation = "default"
	if big_Chunky:
		return
	super()
	
