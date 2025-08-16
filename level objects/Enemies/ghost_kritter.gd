class_name GhostKritter
extends Baddy

@export var hide_time:float = 2.0
@export var expose_time:float = 4.0

@onready var hide_timer: Timer = $Timers/hide_timer
#@onready var sprite: AnimatedSprite2D = %ghost_sprite
@onready var spooky_sound: AudioStreamPlayer2D = $Sounds/spooky_sound
@onready var ghost_animations: AnimationPlayer = %ghost_animations



var hiding:bool = false
signal got_bumped

func _ready() -> void:
	hide_timer.start(expose_time)
	got_bumped.connect(temp_invisible_lost)
	super()
	
func set_sprite_to_child_sprite() -> void:
	sprite = %ghost_sprite
	
func shot_event():
	super()
	ghost_hide()

#Swap ghost between "invisible" and "revealed"
func trigger_invisible_action() -> void:
	if hiding == false:
		ghost_hide()
	else:
		ghost_reveal()
		
func ghost_hide() -> void:
	spooky_sound.play()
	ghost_animations.play("go_invisible")
	hide_shoot_colision()
	hide_timer.start(hide_time)
	hiding = true
func ghost_reveal() -> void:
	spooky_sound.play()
	ghost_animations.play("reveal")
	sprite.visible = true
	reveal_shoot_colision()
	hide_timer.start(expose_time)
	hiding = false

func temp_invisible_lost() -> void:
	var temp_time: float = hide_timer.time_left
	hide_timer.stop()
	ghost_animations.play("temp_reveal")
	await ghost_animations.animation_finished
	hide_timer.start(temp_time)

func _on_hide_timer_timeout() -> void:
	trigger_invisible_action()
