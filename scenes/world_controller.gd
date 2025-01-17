extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var boss = get_tree().get_first_node_in_group("boss")
	boss.set_healthbar(%BossHealthBar)
	
