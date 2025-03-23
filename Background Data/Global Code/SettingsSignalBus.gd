extends Node

#Accessiblity/Advance options signals
signal on_subtitles_toggled(value : bool)
signal on_dash_stomp_toggled(value :bool)
signal on_autofire_toggled(value : bool)
# Window options signals
signal on_window_mode_selected(index : int)
signal on_resolution_selected(index : int)

# Audio options signals
signal on_master_sound_set(value: float)
signal on_music_sound_set(value: float)
signal on_sfx_sound_set(value: float)

#Set Dicitonary Signal (For settings and level data)
signal set_settings_dictionary(settings_dict : Dictionary)
signal load_settings_data(settings_dict : Dictionary)
signal set_levels_dictionary(levels_dict : Dictionary)
signal load_levels_data(levels_dict : Dictionary)



# Dictionary functions
#Settings:
func emit_load_settings_data(settings_dict : Dictionary) -> void:
	load_settings_data.emit(settings_dict)
func emit_set_settings_dictionary(settings_dict : Dictionary) -> void:
	set_settings_dictionary.emit(settings_dict)
#Levels:
func emit_load_levels_data(levels_dict  : Dictionary) -> void:
	load_levels_data.emit(levels_dict)
func emit_set_levels_dictionary(levels_dict  : Dictionary) -> void:
	set_levels_dictionary.emit(levels_dict )

#Accessiblity/Advance options functions
func emit_on_subtitles_toggled(value: bool) -> void:
	on_subtitles_toggled.emit(value)

func emit_on_dash_stomp_toggled(value: bool) -> void:
	on_dash_stomp_toggled.emit(value)
	
func emit_on_autofire_toggled(value: bool) -> void:
	on_autofire_toggled.emit(value)
	
# Window options functions
func emit_on_window_mode_selected(value: int) -> void:
	on_window_mode_selected.emit(value)
	
func emit_on_resolution_selected(value: int) -> void:
	on_resolution_selected.emit(value)

# Audio options functions
func emit_on_master_sound_set(value: float) -> void:
	on_master_sound_set.emit(value)
	
func emit_on_music_sound_set(value: float) -> void:
	on_music_sound_set.emit(value)
	
func emit_on_sfx_sound_set(value: float) -> void:
	on_sfx_sound_set.emit(value)
	
