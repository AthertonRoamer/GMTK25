class_name InputActionRotationChange
extends InputAction

var rotation : float = 0

func _init(a : String = "", f : int = 0, r : float = 0) -> void:
	action_name = a
	frame = f
	rotation = r
	
	
func print() -> void:
	print( "Frame: ", frame, " Name: ", action_name, " Rotation: ", rotation)
