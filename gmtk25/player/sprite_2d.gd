extends Sprite2D

@export var parent:Node2D
var parent_prev_position:Vector2
var parent_curr_position:Vector2

func _physics_process(_delta):
	parent_prev_position = parent_curr_position
	parent_curr_position = parent.global_position
	
	
func _process(_delta):
	var factor=Engine.get_physics_interpolation_fraction()
	self.global_position.x = parent_prev_position.x + (parent_curr_position.x - parent_prev_position.x) * factor
	self.global_position.y = parent_prev_position.y + (parent_curr_position.y - parent_prev_position.y) * factor
func _ready():
	if(!parent):
		parent=get_parent()

	if("global_position" in parent):
		parent_prev_position=parent.global_position
		parent_curr_position=parent.global_position
	else:
		set_process(false)
		set_physics_process(false)
