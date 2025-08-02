class_name InputAction
extends RefCounted

var action_name : String
var frame : int = 0

func _init(a : String = "", f : int = 0) -> void:
	action_name = a
	frame = f
	
	
func print() -> void:
	print( "Frame: ", frame, " Name: ", action_name,)
