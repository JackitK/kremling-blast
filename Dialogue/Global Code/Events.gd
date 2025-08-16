extends Node
signal enemy_hit(value : int)
signal ally_hit(value : int)
signal game_over
signal will_you_continue(value: bool)
signal level_cleared
signal banana_tally(value : int)
signal power_up
signal shot_triggered
signal score_tally(value: int)
signal click_score_tally(value:int)
signal back_to_start_menu
signal save_the_game
signal hits_to_win(value: int)
signal play_sound(value:String)
signal current_score_update()
signal pause_prompt()
signal kong_button_prompt()
signal kong_selection(value:String)
signal live_update_settings()
signal hide_while_in_options()

var enable_banana_movement: bool = false
var has_mobile_warning_been_displayed:bool = false
var total_score: int = 0
#var used to track number of misses/lives between levels. Only used for certain challenges.
var global_lives: int = 5 



	

func emit_enemy_hit(value: int) -> void:
	enemy_hit.emit(value)

func emit_ally_hit(value: int) -> void:
	ally_hit.emit(value)
	
func emit_game_over() -> void:
	game_over.emit()
	
func emit_will_you_continue(value:bool) -> void:
	will_you_continue.emit(value)

func emit_level_cleared() -> void:
	level_cleared.emit()

func emit_banana_tally(value: int) -> void:
	banana_tally.emit(value)
	
func emit_power_up() -> void:
	power_up.emit()

func emit_shot_triggered() -> void:
	shot_triggered.emit()

func emit_score_tally(value: int) -> void:
	score_tally.emit(value)
	
func emit_click_score_tally(value:int) -> void:
	click_score_tally.emit(value)
func emit_back_to_start_menu() -> void:
	back_to_start_menu.emit()
func emit_save_the_game() -> void:
	save_the_game.emit()
	
func emit_hits_to_win(value: int) -> void:
	hits_to_win.emit(value)
	
func emit_play_sound(value:String) -> void:
	play_sound.emit(value)
	
func emit_confirm_kong_selection(kong:String) -> void:
	kong_selection.emit(kong)
	
func set_score(score:int) -> void:
	total_score = score

func send_score() -> int:
	return total_score

func emit_current_score_update() -> void:
	current_score_update.emit()
	
func emit_pause_prompt() -> void:
	pause_prompt.emit()
	
func emit_kong_button_prompt() -> void:
	kong_button_prompt.emit()
	
func emit_live_update_settings() -> void:
	live_update_settings.emit()
	
func emit_hide_while_in_options() -> void:
	hide_while_in_options.emit()
	
# To hopefull reduce leaks caused by custom mouse cursor (and maybe custom mouse events)
func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null)

func reset_highscore() -> void:
	print("resetting score")
	SaveManager.save_data.high_score = 0
	SaveManager.save_data.endless_score = 0


func load_audio_settings() -> void:
	var master_vl = linear_to_db(SettingsDataContainer.get_master_sound())
	var music_vl = linear_to_db(SettingsDataContainer.get_music_sound())
	var sfx_vl = linear_to_db(SettingsDataContainer.get_sfx_sound())
	
	AudioServer.set_bus_volume_db(0, master_vl)
	AudioServer.set_bus_volume_db(1, music_vl)
	AudioServer.set_bus_volume_db(2, sfx_vl)

func load_graphics_settings() -> void:
	var window_index : int = SettingsDataContainer.window_mode_index
	match window_index:
		0: #window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: #Borderless Window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: #Borderless Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	const STARTING_RESOLUTION_DICTIONARY : Dictionary = {
	"1152 x 648" : Vector2i(1152, 648),
	"960 x 540" : Vector2i(960, 540),
	"1280 x 720" : Vector2i(1280, 720),
	"1920 x 1080" : Vector2i(1920, 1080)
	}
	
	var resolution_index : int = SettingsDataContainer.resolution_index
	DisplayServer.window_set_size(STARTING_RESOLUTION_DICTIONARY.values()[resolution_index])
