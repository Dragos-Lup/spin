extends Area2D

var enabled = true

func _on_body_entered(body:Node2D) -> void:
	if enabled and body.is_in_group("player"):
		print("HEALING DONE")
		body.health_component.Heal(10)
		get_parent().health_component.Damage(15)
		disable()


func disable() -> void:
	self.visible = false
	enabled = false

func enable() -> void:
	self.visible = true
	enabled = true
	self.rotation = randf() * 360
