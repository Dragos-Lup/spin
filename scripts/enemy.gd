extends RigidBody2D

@export var health_component: Node2D
@export var collision_shape: Node2D
# Called when the node enters the scene tree for the first time.

func set_healthbar(node : ProgressBar):
	
	health_component.boss_health_bar = node
	node.max_value = health_component.max_health
	node.value = health_component.current_health
	
