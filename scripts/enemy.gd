extends RigidBody2D

@export var health_component: Node2D
@export var collision_shape: Node2D
# Called when the node enters the scene tree for the first time.

func set_healthbar(node : ProgressBar):
	health_component.boss_health_bar = node #The node we got send is the health bar, change the health_component accordingly
	#Set the max value and value of the health bar
	node.max_value = health_component.max_health 
	node.value = health_component.current_health
	
