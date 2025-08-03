class_name CodeDisplay
extends Label

var code : int = 0:
	set(v):
		code = v
		text = "CODE:\n " + str(v) + " "
		
		
func activate(b : bool) -> void:
	visible = b
	
	
func _ready() -> void:
	visible = false
