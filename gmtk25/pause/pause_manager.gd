class_name PauseManager
extends Node

signal true_pause(b : bool)

func announce_pause(b : bool) -> void:
	true_pause.emit(b)
