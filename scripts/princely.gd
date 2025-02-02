extends RigidBody2D

# THIS IS PRINCELY

@onready var health_component: Node2D = $HealthComponent
@onready var collision_shape: Node2D = $CollisionShape2D
@onready var mc: Node2D = $MovementComponent
@onready var DashTimer: Timer = $DashTimer
@onready var TargetTimer: Timer = $UnTargettingTimer
@onready var laser: Line2D = %Laser
@onready var laser_particles : GPUParticles2D = $LaserEndParticles
@onready var flame_wave = preload("res://scenes/saphire_projectile.tscn")
@onready var player #It's important that literally nothing else in the scene is called one of these two things
# @onready var follower = %follower #For testing

enum Move_State {IDLE, TARGETING, CIRCLING, LOCKED_ON, LASER, FADED, CRAZY, SLICE, DYING}
#List of states, you can add a new one if you want a new behavior
var curr_state = Move_State.CIRCLING #The state the boss starts in
var profile_anim : AnimationPlayer

@export var MAX_FORCE: float = 10 #Set in editor technically, but tweak it in here idc lol
@export var CIRCLE_SPEED: float = 100
@export var DASH_SPEED: float = 9000
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
var laser_target: Vector2 = Vector2.ZERO

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var timer: float = 0

var circle_timer : float = 2
var laser_timer : float = 2
var max_lasers = 3

var laser_count = max_lasers

var max_dashes = 3
var dash_count = max_dashes

var max_slices = 4
var slice_count = max_slices

var slice_next = false

func _ready() -> void:
	laser.visible = false
	setup()


func set_healthbar(node : TextureProgressBar):
	health_component.boss_health_bar = node #The node we got send is the health bar, change the health_component accordingly
	#Set the max value and value of the health bar
	node.max_value = health_component.max_health 
	node.value = health_component.current_health

func set_profile_animator(node : AnimationPlayer):
	profile_anim = node


func _physics_process(delta: float) -> void:
	timer += delta
	var pos = self.transform.origin

	if $explosion.emitting == true:
		timer += delta
		if timer > (1.0/2.0):
			#%explode_SE.play()
			timer -= (1.0/2.0)

	if is_dead or !player:
		return
	# This should be before state targeting.
	if dashing and linear_velocity.length() < DASH_MINSPEED:
		dashing = false

	# It's important that this state diagram only switches who we are targeting
	match curr_state:
		Move_State.TARGETING: #If we're running right at the player
			target = player.transform.origin #Our target is just the player origin
		Move_State.CIRCLING:
			target = mc.get_encircle(player.transform.origin, encircleR, 250) #Target the mc's surrounding to circle them
			if timer >= circle_timer:
				
				timer-= circle_timer
				if slice_next:
					rand_state()
					slice_next = false
				else:
					switch_laser()
					slice_next = true
		Move_State.LASER:
			target = mc.get_encircle(player.transform.origin, encircleR, 250) #Target the mc's surrounding to circle them
			laser.remove_point(1)
			laser_target = laser_target.lerp(player.position, .1)
			var p = (laser_target - self.position)
			laser.add_point(p)
			if timer >= laser_timer:
<<<<<<< Updated upstream
=======
				$LaserPew.play()
				$shoot_particles.emitting = true
>>>>>>> Stashed changes
				laser_count -= 1
				timer -= laser_timer
				var fw : Node2D = flame_wave.instantiate()
				self.add_sibling(fw)
				fw.position = self.position
				fw.rotation = self.position.angle_to_point(player.position)
				fw.direction = Vector2(1,0).rotated(self.position.angle_to_point(player.position))
				laser.visible = false

				if laser_count <= 0:
					rand_state()
					laser_count = max_lasers
				else:
					curr_state = Move_State.CIRCLING
		Move_State.CRAZY:
			if timer >= 2:
				timer -= 2
				TargetTimer.start()
				dashing = true
				apply_impulse((player.position - pos).normalized() * DASH_SPEED) #Apply that big boy impulse
				dash_count -= 1
				if dash_count <= 0:
					dash_count = max_dashes
					rand_state()
				else:
					pass
		Move_State.SLICE:
			target = mc.get_encircle(player.transform.origin, encircleR, 100) #Target the mc's surrounding to circle them
			if timer >= 2:
				timer -= 2
				$sword_slice.rotation = self.position.angle_to_point(player.position)
				state_machine.travel("sword_slice")
				slice_count -= 1
				if slice_count <= 1:
					slice_count = max_slices
					rand_state()
				else:
					pass


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

			pass

	
	encircleR += delta * CIRCLE_SPEED
	if encircleR >= 360:
		encircleR = encircleR - 360
	
	if target and target != Vector2.ZERO:
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
	curr_state = Move_State.DYING
	is_dead = true
	timer = 0
	laser.visible = false
	linear_velocity = Vector2(0,0)
	state_machine.travel("die")

func fight_done() -> void:
	get_parent().princely_died()
	self.queue_free()

func switch_laser() -> void:
	curr_state = Move_State.LASER
	laser.visible = true
	print("hello?")

func rand_state() -> void:
	var i = randi_range(0,2)
	if i == 0:
		curr_state = Move_State.CIRCLING
	if i == 1:
		curr_state = Move_State.SLICE
	if i == 2:
		curr_state = Move_State.CRAZY
		state_machine.travel("chains_out")
		target = Vector2.ZERO
