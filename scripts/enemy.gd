extends RigidBody2D

@onready var health_component: Node2D = $HealthComponent
@onready var collision_shape: Node2D = $CollisionShape2D
@onready var mc: Node2D = $MovementComponent
@onready var DashTimer: Timer = $DashTimer
@onready var TargetTimer: Timer = $UnTargettingTimer
@onready var player = %MainSpinner #It's important that literally nothing else in the scene is called one of these two things
@onready var follower = %follower #For testing
@onready var ray_casts = [$RayCasts/DLray, $RayCasts/ULray, $RayCasts/URray, $RayCasts/DRray]

enum Move_State {IDLE, TARGETING, CIRCLING, LOCKED_ON} #List of states, you can add a new one if you want a new behavior
var curr_state = Move_State.CIRCLING #The state the boss starts in

@export var MAX_FORCE: float = 10 #Set in editor technically, but tweak it in here idc lol
@export var CIRCLE_SPEED: float = 100

var can_collide = [true, true, true, true]
var target: Vector2 = Vector2(940,530)
var encircleR: float = 0.0
var go: bool = false
var dash_target: Vector2 = Vector2.ZERO


func _ready() -> void:
	setup()
	pass


func set_healthbar(node : TextureProgressBar):
	health_component.boss_health_bar = node #The node we got send is the health bar, change the health_component accordingly
	#Set the max value and value of the health bar
	node.max_value = health_component.max_health 
	node.value = health_component.current_health


func _physics_process(delta: float) -> void:
	var pos = self.transform.origin
	# It's important that this state diagram only switches who we are targeting
	if curr_state == Move_State.TARGETING: #If we're running right at the player
		target = player.transform.origin #Our target is just the player origin
	elif curr_state == Move_State.CIRCLING:
		target = mc.get_encircle(player.transform.origin, encircleR) #Target the mc's surrounding to circle them
		follower.transform.origin = target #TODO: delete this later
		for i in range(4):
			if ray_casts[i].is_colliding() and can_collide[i]: #If one of the ray casts hit
				can_collide[i] = false #Don't use the same raycast again
				dash_target = ray_casts[i].get_collider().transform.origin #Save that player position for later
				var vec = (dash_target - pos).normalized() * -1 #We want to go to the direction opposite of the player
				target = vec * 30 + pos #Move slightly away from the player
				set_linear_velocity(Vector2.ZERO) #Completely stop moving
				curr_state = Move_State.LOCKED_ON #Now we're gonna be locked on, and waiting to dash
				go = false #Make sure go is false (this actually does nothing technicaly)
				DashTimer.start() #Start the dash timer to dash in a couple of seconds
	elif curr_state == Move_State.LOCKED_ON:
		if go: #If its time to dash
			go = false #Make sure go is false next time
			curr_state = Move_State.TARGETING #Set the state to targeting the player
			TargetTimer.start() #We only wanna be targeting for a couple of seconds post dash, then go back to circling

			apply_impulse((dash_target - pos).normalized() * 50000) #Apply that big boy impulse

	encircleR += delta * CIRCLE_SPEED
	if encircleR >= 360:
		encircleR = encircleR - 360
	
	if target:
		#Moves the rigidbody to the target location
		#get_force takes in the rb2ds location, where we wanna go, our current velocity (should always be linear_velocity) and delta
		apply_central_force(mc.get_force(pos, target, linear_velocity, delta))
		

func setup() -> void: #Sets up the movement controller
	mc.set_mass(self.mass) 
	mc.set_max_force(MAX_FORCE)

func _on_un_targetting_timer_timeout() -> void:
	#once the timer finishes, change our current state back to circling.
	curr_state = Move_State.CIRCLING

func _on_dash_timer_timeout() -> void:
	#Once the timer runs out, go dash!
	go = true
