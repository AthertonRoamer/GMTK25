class_name InputRecord
extends RefCounted

var loop_index : int = 1
var death_frame : int = -1
var seconds_remaining_at_death : float = 0
var input_action_list : Array[InputAction] #smaller index means earlier

var incomplete : bool = false

func print_action_list() -> void:
	for action in input_action_list:
		action.print()
