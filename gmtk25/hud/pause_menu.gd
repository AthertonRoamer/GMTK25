extends VBoxContainer
	
signal pause_menu_open_changed(pause_menu_open : bool)

var final_loop_menu : bool = false
var pause_menu_open : bool = false:
	set(v):
		pause_menu_open = v
		pause_menu_open_changed.emit(v)
		
		
func _ready() -> void:
	visible = false
	Main.level.loop_manager.final_loop_ended.connect(_on_final_loop_ended)
	
	
func _on_final_loop_ended() -> void:
	final_loop_menu = true
	open_pause_menu()
	
	
func _on_restart_pressed() -> void:
	$"../SavedRunDisplay".waiting_for_true_pause_to_end = false
	$"../SavedRunDisplay".visible = false
	close_pause_menu()
	Main.game.level_manager.reload_active_level()


func _on_quit_to_menu_pressed() -> void:
	close_pause_menu()
	Main.main.exit_game_to_menu()
	
	
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("pause_menu") and not final_loop_menu:
		if pause_menu_open:
			close_pause_menu()
		else:
			open_pause_menu()
	elif event.is_action_pressed("restart_hotkey"):
		if pause_menu_open:
			close_pause_menu()
		Main.game.level_manager.reload_active_level()
			
			
func close_pause_menu() -> void:
	Pause.announce_pause(false)
	pause_menu_open = false
	visible = false
	get_tree().paused = false
	
	
func open_pause_menu() -> void:
	Pause.announce_pause(true)
	pause_menu_open = true
	visible = true
	get_tree().paused = true
			
			
func _exit_tree() -> void:
	get_tree().paused = false
