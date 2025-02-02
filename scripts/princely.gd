extends RigidBody2D

# THIS IS PRINCELY

@onready var health_component: Node2D = $HealthComponent
@onready var collision_shape: Node2D = $CollisionShape2D
@onready var mc: Node2D = $MovementComponent
@onready var DashTimer: Timer = $DashTimer
@onready var TargetTimer: Timer = $UnTargettingTimer
@onready var player #It's important that literally nothing else in the scene is called one of these two things
# @onready var follower = %follower #For testing

enum Move_State {IDLE, TARGETING, CIRCLING, LOCKED_ON, CLONE, FADED} #List of states, you can add a new one if you want a new behavior
var curr_state = Move_State.CIRCLING #The state the boss starts in
var profile_anim : AnimationPlayer

@export var MAX_FORCE: float = 10 #Set in editor technically, but tweak it in here idc lol
@export var CIRCLE_SPEED: float = 100
@export var DASH_SPEED: float = 14000
@export var CIRCLE_DISTANCE: float = 80
@export var DASH_MINSPEED: float = 1000
@export var MAP_CENTER : Vector2 = Vector2(938, 531)

var is_dead: bool = false

# var can_collide = [true, true, true, true] # The raycasts that can still collide

var target: Vector2 = MAP_CENTER #Where we're running into
var encircleR: float = 0.0 #The radius we are encircling around currently
var go: bool = false #dash when this is true
var dash_target: Vector2 = Vector2.ZERO #Dash towards this guy
var dashing: bool = false #are we currently dashing (for damage purposes)
var last_vel: float = 0 #The last velocity (for damage purposes)


func _ready() -> void:
	player = %MainSpinner
		
	setup()


func set_healthbar(node : TextureProgressBar):
	health_component.boss_health_bar = node #The node we got send is the health bar, change the health_component accordingly
	#Set the max value and value of the health bar
	node.max_value = health_component.max_health 
	node.value = health_component.current_health

func set_profile_animator(node : AnimationPlayer):
	profile_anim = node


func _physics_process(delta: float) -> void:
	var pos = self.transform.origin
	if is_dead:
		return
	# This should be before state targeting.
	if dashing and linear_velocity.length() < DASH_MINSPEED:
		dashing = false
	if !player:
		return

	# It's important that this state diagram only switches who we are targeting
	match curr_state:
		Move_State.TARGETING: #If we're running right at the player
			target = player.transform.origin #Our target is just the player origin
		Move_State.CIRCLING:
			target = mc.get_encircle(player.transform.origin, encircleR) #Target the mc's surrounding to circle them
		Move_State.LOCKED_ON:
			if go: #If its time to dash
				go = false #Make sure go is false next time
				curr_state = Move_State.TARGETING #Set the state to targeting the player
				TargetTimer.start() #We only wanna be targeting for a couple of seconds post dash, then go back to circling

				apply_impulse((dash_target - pos).normalized() * DASH_SPEED) #Apply that big boy impulse
				dashing = true

				$Jesterlaugh.play()
				$Jestersparkle.play()
				$Jestercharge.stop()
				$JesterWoosh.play()
			else:
				pass
				# set_linear_velocity((dash_target-pos).normalized()*-2 )
		Move_State.FADED:
			#Man this shit nice
			pass
		Move_State.IDLE:
			target = self.position
		Move_State.CLONE:
			target = player.transform.origin #Our target is just the player origin

			pass

	
	encircleR += delta * CIRCLE_SPEED
	if encircleR >= 360:
		encircleR = encircleR - 360
	
	if target:
		#Moves the rigidbody to the target location
		#get_force takes in the rb2ds location, where we wanna go, our current velocity (should always be linear_velocity) and delta
		apply_central_force(mc.get_force(pos, target, linear_velocity, delta))
	last_vel = linear_velocity.length()

func setup() -> void: #Sets up the movement controller
	mc.set_mass(self.mass) 
	mc.set_max_force(MAX_FORCE)

func fading_out() -> void:
	$AnimationPlayer.play("fade_out")
	curr_state = Move_State.FADED
	target = self.position

func _on_dash_timer_timeout() -> void:
	#Once the timer runs out, go dash!
	go = true
	$JesterDashTrail.emitting = true

func is_dashing() -> bool:
	return dashing

#This uses last_vel instead of current vel, thats important
func calc_momentum() -> float:
	return mass * last_vel

func kill_those_kids(_x):
	pass
func die() -> void:
	curr_state = Move_State.IDLE
	is_dead = true
	$AnimationPlayer.play("die")

func fight_done() -> void:
	get_parent().jester_died()
	self.queue_free()
