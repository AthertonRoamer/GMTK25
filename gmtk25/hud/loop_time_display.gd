class_name LoopTimeDisplay
extends Label


var loop_manager : LoopManager
func _ready() -> void:
	loop_manager = Main.level.loop_manager
	
	
func _physics_process(_delta: float) -> void:
	text = " " + str(round(loop_manager.current_loop_time * 100) / 100) + " "
