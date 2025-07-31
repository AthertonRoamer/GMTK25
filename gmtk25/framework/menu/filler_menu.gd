extends Control

@export var auto_start : bool = false

func _ready() -> void:
	if auto_start:
		print("Filler menu autostarting")
		Main.main.load_game()


func _on_start_pressed() -> void:
	Main.main.load_game()
