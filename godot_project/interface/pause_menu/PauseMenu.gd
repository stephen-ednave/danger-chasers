extends CanvasLayer

export(String) var game_path : String
export(String) var main_menu_path : String
export(String) var restart_transition_in_animation : String
export(float) var restart_transition_in_duration := 0.5
export(String) var quit_transition_in_animation : String
export(float) var quit_transition_in_duration := 0.5

onready var pause_menu : Control = $Pause
onready var settings_menu : Control = $Settings
onready var input_menu : InputMenu = $InputMenu
onready var menus = [pause_menu, settings_menu]
enum Menus { PAUSE, SETTINGS, INPUT }

var current_menu


func _ready() -> void:
	hide_menus()


func pause() -> void:
	change_menu(Menus.PAUSE)
	get_tree().paused = true


func unpause() -> void:
	for menu in menus:
		menu.visible = false
	get_tree().paused = false
	pause_menu.get_node("UnpauseSfx").play()


func _input(event : InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not get_tree().paused:
			pause()
			return
		
		if current_menu == Menus.PAUSE:
			unpause()
		elif current_menu == Menus.SETTINGS:
			change_menu(Menus.PAUSE)
		elif current_menu == Menus.INPUT:
			change_menu(Menus.SETTINGS)



func change_menu(new_menu) -> void:
	current_menu = new_menu
	
	hide_menus()
	if current_menu == Menus.PAUSE:
		pause_menu.visible = true
		pause_menu.get_node("Buttons").get_child(0).grab_focus()
		pause_menu.get_node("PauseSfx").play()
	elif current_menu == Menus.SETTINGS:
		settings_menu.visible = true
		settings_menu.get_node("Buttons").get_child(0).grab_focus()
		pause_menu.get_node("PauseSfx").play()
	elif current_menu == Menus.INPUT:
		pause_menu.get_node("PauseSfx").play()
		input_menu.enable()


func hide_menus() -> void:
	for menu in menus:
		menu.visible = false




func _on_Resume_button_down():
	unpause()


func _on_Restart_button_down():
	yield(Transition.transition_in(restart_transition_in_animation, restart_transition_in_duration), "transition_in_finished")
	GameManager.game.level_loader.change_level(GameManager.current_loaded_level, GameManager.initial_spawn_point)
	unpause()


func _on_Quit_button_down():
	yield(Transition.transition_in(quit_transition_in_animation, quit_transition_in_duration), "transition_in_finished")
	GameManager.clear()
	GameManager.current_loaded_level = load(main_menu_path)
	get_tree().change_scene(game_path)
	unpause()


func _on_Settings_button_down():
	change_menu(Menus.SETTINGS)


func _on_Music_button_down():
	settings_menu.get_node("MusicLevelController").enable()


func _on_Music_focus_exited():
	settings_menu.get_node("MusicLevelController").disable()


func _on_Sfx_button_down():
	settings_menu.get_node("SoundLevelController").enable()


func _on_Sfx_focus_exited():
	settings_menu.get_node("SoundLevelController").disable()


func _on_Controls_button_down():
	change_menu(Menus.INPUT)


func _on_SettingsBack_button_down():
	change_menu(Menus.PAUSE)


func _on_InputMenu_finished():
	change_menu(Menus.SETTINGS)


func _on_Ambience_button_down():
	settings_menu.get_node("AmbienceLevelController").enable()


func _on_Ambience_focus_exited():
	settings_menu.get_node("AmbienceLevelController").disable()
