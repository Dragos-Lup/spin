extends RigidBody2D

@onready var health_component: Node2D = $HealthComponent
@onready var collision_shape: Node2D = $CollisionShape2D
@onready var mc: Node2D = $MovementComponent
@onready var DashTimer: Timer = $DashTimer
@onready var TargetTimer: Timer = $UnTargettingTimer
@onready var player #It's important that literally nothing else in the scene is called one of these two things
# @onready var follower = %follower #For testing
@onready var ray_casts = [$RayCasts/DLray, $RayCasts/ULray, $RayCasts/URray, $RayCasts/DRray]
@onready var baby_boy = load("res://scenes/jester_little_guy.tscn")

enum Move_State {IDLE, TARGETING, CIRCLING, LOCKED_ON, CLONE, FADED} #List of states, you can add a new one if you want a new behavior
var curr_state = Move_State.CIRCLING #The state the boss starts in

@export var MAX_FORCE: float = 10 #Set in editor technically, but tweak it in here idc lol
@export var CIRCLE_SPEED: float = 100
@export var DASH_SPEED: float = 14000
@export var CIRCLE_DISTANCE: float = 80
@export var DASH_MINSPEED: float = 1000
@export var MAP_CENTER : Vector2 = Vector2(938, 531)

var can_collide = [false, false, true, false] # The raycasts that can still collide
var target: Vector2 = Vector2(940,530) #Where we're running into
var encircleR: float = 0.0 #The radius we are encircling around currently
var go: bool = false #dash when this is true
var dash_target: Vector2 = Vector2.ZERO #Dash towards this guy
var dashing: bool = false #are we currently dashing (for damage purposes)
var last_vel: float = 0 #The last velocity (for damage purposes)
var clone: bool = false

func _ready() -> void:
	if !clone:
		player = %MainSpinner
		
	setup()


func set_healthbar(node : TextureProgressBar):
	health_component.boss_health_bar = node #The node we got send is the health bar, change the health_component accordingly
	#Set the max value and value of the health bar
	node.max_value = health_component.max_health 
	node.value = health_component.current_health


func _physics_process(delta: float) -> void:
	var pos = self.transform.origin

	# This should be before state targeting.
	if dashing and linear_velocity.length() < DASH_MINSPEED:
		dashing = false


	# It's important that this state diagram only switches who we are targeting
	match curr_state:
		Move_State.TARGETING: #If we're running right at the player
			target = player.transform.origin #Our target is just the player origin
		Move_State.CIRCLING:
			target = mc.get_encircle(player.transform.origin, encircleR) #Target the mc's surrounding to circle them
			# follower.transform.origin = target #TODO: delete this later
			for i in range(4):
				if ray_casts[i].is_colliding() and can_collide[i]: #If one of the ray casts hit
					$Jestercharge.play()
					can_collide[i] = false #Don't use the same raycast again
					dash_target = ray_casts[i].get_collider().transform.origin #Save that player position for later
					var vec = (dash_target - pos).normalized() * -1 #We want to go to the direction opposite of the player
					target = vec * CIRCLE_DISTANCE + pos #Move slightly away from the player
					set_linear_velocity(Vector2.ZERO) #Completely stop moving
					curr_state = Move_State.LOCKED_ON #Now we're gonna be locked on, and waiting to dash
					go = false #Make sure go is false (this actually does nothing technicaly)
					DashTimer.start() #Start the dash timer to dash in a couple of seconds
		Move_State.LOCKED_ON:
			if go: #If its time to dash
				go = false #Make sure go is false next time
				curr_state = Move_State.TARGETING #Set the state to targeting the player
				TargetTimer.start() #We only wanna be targeting for a couple of seconds post dash, then go back to circling

				apply_impulse((dash_target - pos).normalized() * DASH_SPEED) #Apply that big boy impulse
				dashing = true

				$Jesterlaugh.play()
				$Jestercharge.stop()
			else:
				pass
				# set_linear_velocity((dash_target-pos).normalized()*-2 )
		Move_State.FADED:
			#Man this shit nice
			pass
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

func _on_un_targetting_timer_timeout() -> void:
	#once the timer finishes, change our current state back to circling.
	for x in can_collide:
		if x:
			curr_state = Move_State.CIRCLING
			return
	if !clone:
		fading_out()

func fading_out() -> void:
	$AnimationPlayer.play("fade_out")
	curr_state = Move_State.FADED
	target = self.position

func _on_dash_timer_timeout() -> void:
	#Once the timer runs out, go dash!
	go = true

func is_dashing() -> bool:
	return dashing

#This uses last_vel instead of current vel, thats important
func calc_momentum() -> float:
	return mass * last_vel

func spawn_clones() -> void:
	#Clones should differ very very slightly from parent
	#Maybe a different animation speed?
	if (!clone):
		var n : float = 3
		for i in range(n):
			var lguy = baby_boy.instantiate(2)
			lguy.player = player
			lguy.clone = true
			lguy.curr_state = Move_State.CIRCLING

			var name_guy = "littleguy" + str(i)
			lguy.set_name(name_guy)
			get_tree().root.add_child(lguy)
			lguy.health_component.max_health = 10
			
			lguy.health_component.current_health = 10

			lguy.set_position((MAP_CENTER) + Vector2.UP.rotated(deg_to_rad(360 * (i/n))) * 250)
