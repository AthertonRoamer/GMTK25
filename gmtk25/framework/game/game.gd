class_name Game
extends Node

@onready var level_manager : LevelManager = $LevelManager
@onready var level_menu : LevelMenu = $LevelMenu
@export var level_menu_enabled : bool = false

#this is THE game
func get_active_level() -> Level:
	return level_manager.active_level

	
func _ready() -> void:
	Main.game = self
	level_menu.level_manager = level_manager
	level_menu.build_menu()
	if not level_menu_enabled:
		level_manager.open_first_level()
	else:
		level_menu.activate()
	
