class_name LoopCountDisplay
extends Label

var loop_manager : LoopManager
func _ready() -> void:
	loop_manager = Main.level.loop_manager
	loop_manager.loop_began.connect(_on_loop_began)
	visible = false
	
	
func _on_loop_began() -> void:
	visible = true
	text = "Loop " + str(loop_manager.current_loop)
