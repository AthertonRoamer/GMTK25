class_name PlayerHealthDisplay
extends ProgressBar

var health : float = 100:
	set(v):
		if v > 100:
			health = 100
		if v < 0:
			v = 0
		update_display()
		
		
func update_display() -> void:
	value = health
