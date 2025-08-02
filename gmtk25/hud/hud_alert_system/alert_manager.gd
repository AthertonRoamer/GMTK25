class_name AlertManager
extends Control

var alert_scene : PackedScene = preload("res://hud/hud_alert_system/alert.tscn")

func add_alert(message : String = "Alert", time : float = 2.0) -> void:
	var a : Alert = alert_scene.instantiate()
	a.message = message
	a.display_time = time
	add_child(a)
