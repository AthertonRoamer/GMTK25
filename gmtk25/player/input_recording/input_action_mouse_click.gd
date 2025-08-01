class_name InputActionMouseClick
extends InputAction

var global_mouse_position : Vector2

func _init(a : String = "", f : int = 0, v : Vector2 = Vector2.ZERO) -> void:
	action_name = a
	frame = f
	global_mouse_position = v
