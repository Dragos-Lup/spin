extends Area2D

var direction = Vector2.ZERO
var speed = 600

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	position += direction.normalized() * speed * delta


func _on_body_entered(body:Node2D) -> void:
	body.health_component.Damage(10)
