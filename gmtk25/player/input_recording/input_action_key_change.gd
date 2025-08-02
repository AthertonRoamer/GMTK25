class_name InputActionKeyChange
extends InputAction

var pressed : bool = false

func _init(a : String = "", f : int = 0, p : bool = false) -> void:
	action_name = a
	frame = f
	pressed = p
	
	
func print() -> void:
	print("Frame: ", frame, " Name: ", action_name, " Pressed: ", pressed)
