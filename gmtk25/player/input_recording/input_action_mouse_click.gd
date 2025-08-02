class_name InputActionMouseClick
extends InputAction

var global_mouse_position : Vector2

func _init(a : String = "", f : int = 0, v : Vector2 = Vector2.ZERO) -> void:
	action_name = a
	frame = f
	global_mouse_position = v
	
	
func print() -> void:
	print("Frame: ", frame, " Name: ", action_name, " Position: ", global_mouse_position)
