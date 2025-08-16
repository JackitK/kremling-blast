class_name KlapTrap
extends Baddy

@onready var chomp_sound: AudioStreamPlayer2D = %chomp_sound

func set_sprite_to_child_sprite() -> void:
	sprite = $sprite_klapTrap

func _on_nearby_dector_area_entered(area: Area2D) -> void:
	if area.is_in_group("breakable_block"):
		var block = area.get_parent()
		if block is BreakableBlock:
			print("klap trap bump block")
			if block.wall_type == "wood":
				print("klap trap bump wood")
				chomp_wood(block)
			else:
				block.collide_event.emit(weight)
				
func chomp_wood(target) -> void:
	if target is BreakableBlock:
		chomp_sound.play()
		target.destroy_self.emit()
