class_name Alert
extends VBoxContainer

var display_time : float = 1
var message : String = "Text"

func _ready() -> void:
	$Label.text = message
	$Timer.wait_time = display_time
	$Timer.start()


func _on_timer_timeout() -> void:
	queue_free()
