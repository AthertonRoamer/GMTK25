class_name Map
extends Node2D

@export var spawn_point : Node2D
var players : Array[Player] = []
var active : bool = false

func set_players_active(p_active : bool) -> void:
	for player in players:
		player.active = p_active
