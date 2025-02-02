extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	self.queue_free()



func _on_body_entered(body:Node2D) -> void:
	body.set_fiora()

