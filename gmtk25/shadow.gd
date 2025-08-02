extends ColorRect

var tween

func _ready():
	self.visible = true
	modulate.a = 1.0  # Fully opaque

func activate(_is_active: bool):
	reveal_area()

func reveal_area():
	kill_tween()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func hide_area():
	kill_tween()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func kill_tween():
	if tween and tween.is_running():
		tween.kill()
