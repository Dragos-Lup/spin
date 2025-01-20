extends RigidBody2D

@export var health_component: Node2D
@export var collision_shape: Node2D
# Called when the node enters the scene tree for the first time.

enum Move_State {IDLE, TARGETING}

var curr_state = Move_State.TARGETING

@onready var player = %MainSpinner

var target: Vector2 = Vector2(940,530)

var checkTarget: bool = true

func set_healthbar(node : ProgressBar):
	health_component.boss_health_bar = node #The node we got send is the health bar, change the health_component accordingly
	#Set the max value and value of the health bar
	node.max_value = health_component.max_health 
	node.value = health_component.current_health

func _physics_process(_delta: float) -> void:
	var force = Vector2.ZERO
	if curr_state == Move_State.TARGETING:
		target = player.transform.origin
	if target:
		force = 10 * (target - self.transform.origin) - linear_velocity
	apply_central_force(force)
	if checkTarget and randfn(0,1) < .9:
		# print("BOOSTED")
		checkTarget = false
		apply_impulse(((target - self.transform.origin).orthogonal() + (target - self.transform.origin)).normalized() * 5000)
	# curr_state = Move_State.IDLE


	# elif Input.is_action_pressed("dash"):
		# vel_difference = (target_vel * DASH_SLOW - linear_velocity) #Slows the player down by "DASH_SLOW" amount
	# if Input.is_action_just_released("dash"):
			# apply_impulse(dash_vector * (DASH_SPEED * chargetime/1000)) #Applys the dash amount
			
	# apply_central_force(vel_difference) # Applys regular movement effects (Or slowed from dashing)


func _on_boss_timer_timeout() -> void:
	checkTarget = true

	# var direction := Input.get_vector("left", "right", "up", "down").normalized()
	# var target_vel = direction * SPEED
	# var vel_difference = (target_vel - linear_velocity)
	# Dash Mechanics
	# if Input.is_action_just_pressed("dash"): 
		# dash_start_time = Time.get_ticks_msec() #When did we start charging
	# state_machine.travel("jump") #This is the cool little animation that plays neato!:w
	# Get the current input direction
	# var direction := Input.get_vector("left", "right", "up", "down").normalized()
	# This is where the player wants to be moving. 
	# This is kinda hard to understand, but this is our influence, or how we want to be moving
	# var target_vel = direction * SPEED
	# This is the difference between how we're moving now, and how we want to be moving.
	# var vel_difference = (target_vel - linear_velocity)
	# Dash Mechanics
	# if Input.is_action_just_pressed("dash"): 
		# dash_start_time = Time.get_ticks_msec() #When did we start charging
		# state_machine.travel("jump") #This is the cool little animation that plays neato!
	# elif Input.is_action_pressed("dash"):
		# vel_difference = (target_vel * DASH_SLOW - linear_velocity) #Slows the player down by "DASH_SLOW" amount
	# if Input.is_action_just_released("dash"):
		# var chargetime = Time.get_ticks_msec() - dash_start_time #How long did we charge for?
		# if (chargetime) > 850:
			# var dash_vector = (get_global_mouse_position() - global_position).normalized() #Where we going big boss
			# apply_impulse(dash_vector * (DASH_SPEED * chargetime/1000)) #Applys the dash amount
	#		#TODO: Dashing should have a cap real talk, or scale logarithmically or something
	 		# $Dash_SE.play() #Plays the dash sound effect
			
	# apply_central_force(vel_difference) # Applys regular movement effects (Or slowed from dashing)
	# $Spinning_SE.set_pitch_scale(linear_velocity.length()/950 + 1)
	# spin_bar.value = linear_velocity.length() / 10
