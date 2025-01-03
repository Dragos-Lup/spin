extends CharacterBody2D

const SPEED = 3000.0
const MAX_SPEED = 1000.0
const DASH_SPEED = 2000.0
const FRICTION = 20.0 ## calling this friction is evil, it's the value move_toward uses.
const BOUNCY = .8

var canDash = true

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	var target_vel = (direction * SPEED).clampf(-MAX_SPEED, MAX_SPEED) #This is how fast we want to go
	
	if Input.is_action_just_pressed("dash") && canDash: 
		var dash_vector = (get_global_mouse_position() - global_position).normalized()
		velocity = dash_vector * DASH_SPEED
		canDash = false
		$dashTimer.start()
	
	velocity = velocity.move_toward(target_vel, FRICTION)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * BOUNCY

func _on_timer_timeout() -> void:
	canDash = true
