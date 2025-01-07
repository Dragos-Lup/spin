extends CharacterBody2D

const SPEED = 3000.0
var MAX_SPEED = 1000.0
const DASH_SPEED = 2000.0
const FRICTION = 20.0 ## calling this friction is evil, it's the value move_toward uses.
const BOUNCY = .8
const DASH_SLOW = .2

@onready var spin_bar: ProgressBar = %SpinBar
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")



var dash_start_time = 0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	var target_vel = (direction * SPEED).limit_length(MAX_SPEED) #This is how fast we want to go

	if Input.is_action_just_pressed("dash"): 
		dash_start_time = Time.get_ticks_msec()
		state_machine.travel("jump")
		MAX_SPEED *= DASH_SLOW
		
	if Input.is_action_just_released("dash"):
		assert(MAX_SPEED == 200)  ## This will need to be removed in final build
		MAX_SPEED *= 1 / DASH_SLOW
		var chargetime = Time.get_ticks_msec() - dash_start_time
		if (chargetime) > 850:
			var dash_vector = (get_global_mouse_position() - global_position).normalized()
			velocity = dash_vector * (DASH_SPEED * chargetime/1000)
	velocity = velocity.move_toward(target_vel, FRICTION)
	print(velocity.length())
	spin_bar.value = velocity.length() / 10
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * BOUNCY
