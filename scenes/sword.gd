extends Area2D

var damage = 15




func _on_body_entered(body:Node2D) -> void:
	body.health_component.Damage(damage)
	print("yello???")
	
