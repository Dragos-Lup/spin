extends CharacterBody2D

const SPEED = 3000.0
var MAX_SPEED = 1000.0
const DASH_SPEED = 2000.0
const FRICTION = 20.0 ## calling this friction is evil, it's the value move_toward uses.
const BOUNCY = .8

@onready var animation_tree: AnimationTree = $AnimationTree

@onready var state_machine = animation_tree.get("parameters/playback")

var canDash = true
var dashing = false
var dash_start_time = 0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	var target_vel = (direction * SPEED).clampf(-MAX_SPEED, MAX_SPEED) #This is how fast we want to go
	
	if Input.is_action_just_pressed("dash"): 
		dash_start_time = Time.get_ticks_msec()
		state_machine.travel("jump")
		MAX_SPEED *= .25
		canDash = false
		dashing = true
		
	if Input.is_action_just_released("dash"):
		assert(MAX_SPEED == 250)  ## This will need to be removed in final build
		MAX_SPEED *= 4
		var chargetime = Time.get_ticks_msec() - dash_start_time
		if (chargetime) > 850:
			var dash_vector = (get_global_mouse_position() - global_position).normalized()
			velocity = dash_vector * (DASH_SPEED * chargetime/1000)
		
	velocity = velocity.move_toward(target_vel, FRICTION)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * BOUNCY
