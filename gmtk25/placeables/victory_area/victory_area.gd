extends Area2D

func _ready() -> void:
	$Polygon2D.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Timer.start()


func _on_timer_timeout() -> void:
	Main.level.trigger_victory()
