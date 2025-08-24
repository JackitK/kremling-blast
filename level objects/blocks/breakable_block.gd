class_name BreakableBlock
extends Node2D

var mouse_inside: bool = false
#set to true when ever a destroy function is called to avoid repeats/canceling ongoing effects
var block_shot: bool = false 
signal collide_event(weight: String)
signal anti_wood_check(type:String)
signal destroy_self()

const glass_texture: Texture = preload("res://sprite/Field Sprites/glass tile.png")
const wood_texture: Texture = preload("res://sprite/Field Sprites/wood tile.png")
const cracked_texture: Texture = preload("res://sprite/Field Sprites/cracked panel.png")
const target_texture: Texture = preload("res://sprite/Field Sprites/target panel.png")
const re_glass_texture: = preload("res://sprite/Field Sprites/reinforced_glass.png")
@onready var sprite: Sprite2D = $Sprite2D
@onready var break_sound: AudioStreamPlayer2D = $break_sound
@onready var break_trigger_area: Area2D = $break_trigger_area
@onready var wall_area: StaticBody2D = $wall_area


@export_enum("default", "glass", "re_glass", "target", "wood","cracked") var wall_type: String = "default"

func _ready() -> void:
	set_features_tied_to_wall_type()
	Events.shot_triggered.connect(check_for_hit)
	collide_event.connect(block_collision)
	anti_wood_check.connect(destroy_wood)
	break_sound.finished.connect(finish_break_event)
	destroy_self.connect(finish_break_event)
	Events.stop_sounds.connect(stop_all_sounds)

func set_features_tied_to_wall_type() -> void:
	match wall_type:
		"glass":
			sprite.texture = glass_texture
			break_sound.stream = load("res://sounds/sound effects/glass_break.mp3")
		"wood":
			sprite.texture = wood_texture
		"target":
			sprite.texture = target_texture
		"cracked":
			sprite.texture = cracked_texture
		"re_glass":
			sprite.texture = re_glass_texture

func check_for_hit():
	if mouse_inside == true and block_shot == false:
		shoot_block()
		
func block_collision(weight:String):
	# End function if the block has already been shot.
	if block_shot:
		return
	# Run through each block type and run actions specific to that type:
	match wall_type:
		"target":
			return
		"wood":
			return
		"glass","re_glass":
			if weight != "light":
				block_shot = true
				break_sound.play()
				visible = false
				break_trigger_area.call_deferred("queue_free")
				wall_area.call_deferred("queue_free")
			else:
				return
		"cracked":
			if weight == "heavy":
				block_shot = true
				break_sound.play()
				visible = false
				break_trigger_area.call_deferred("queue_free")
				wall_area.call_deferred("queue_free")
		_: # If all other checks fail...
			block_shot = true
			break_sound.play()
			visible = false
			break_trigger_area.call_deferred("queue_free")
			wall_area.call_deferred("queue_free")
		
		
func shoot_block():
	# End function if the block has already been shot
	if block_shot:
		return
	# Run through each block type and run actions specific to that type:
	match wall_type:
		"target", "glass":
			block_shot = true
			break_sound.play()
			visible = false
			break_trigger_area.call_deferred("queue_free")
			wall_area.call_deferred("queue_free")
		"wood", "cracked", "re_glass":
			return
		_: # If all other checks fail...
			block_shot = true
			block_shot = true
			break_sound.play()
			visible = false
			break_trigger_area.call_deferred("queue_free")
			wall_area.call_deferred("queue_free")
		
func destroy_wood(type:String):
	if block_shot:
		return
	else:
		block_shot = true
	match type:
		"chomp":
			break_sound.stream = load("res://sounds/sound effects/Baddies/klaptrap_Chomp.wav")
		"fire":
			break_sound.stream = load("res://sounds/sound effects/Kongs/fire.mp3")
	break_sound.play()
	visible = false
	break_trigger_area.call_deferred("queue_free")
	wall_area.call_deferred("queue_free")
	
func finish_break_event():
	call_deferred("queue_free")

func _on_mouse_entered() -> void:
	mouse_inside = true


func _on_mouse_exited() -> void:
	mouse_inside = false

func stop_all_sounds() -> void:
	break_sound.stop()
