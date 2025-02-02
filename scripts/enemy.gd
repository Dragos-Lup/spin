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

enum Move_State {IDLE, TARGETING, CIRCLING, LOCKED_ON, CLONE, FADED, DYING} #List of states, you can add a new one if you want a new behavior
var curr_state = Move_State.CIRCLING #The state the boss starts in
var profile_anim : AnimationPlayer

@export var MAX_FORCE: float = 10 #Set in editor technically, but tweak it in here idc lol
@export var CIRCLE_SPEED: float = 100
@export var DASH_SPEED: float = 14000
@export var CIRCLE_DISTANCE: float = 80
@export var DASH_MINSPEED: float = 1000
@export var MAP_CENTER : Vector2 = Vector2(938, 531)

var is_dead: bool = false
var can_collide = [true, true, true, true] # The raycasts that can still collide

# var can_collide = [true, false, false, false] # The raycasts that can still collide
var target: Vector2 = Vector2(940,530) #Where we're running into
var encircleR: float = 0.0 #The radius we are encircling around currently
var go: bool = false #dash when this is true
var dash_target: Vector2 = Vector2.ZERO #Dash towards this guy
var dashing: bool = false #are we currently dashing (for damage purposes)
var last_vel: float = 0 #The last velocity (for damage purposes)
var clone: bool = false #Whether or not this is a clone
var father: Node #Father of this node
var children_clones: int = 0 #How many children this dude got
var children_list: Array[Node] #These are this dudes children

var damage_till_clones: float = 0

var timer: float = 0

func _ready() -> void:
	$JesterSpawn.play()
	$WeakSpot.disable()
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
	# if curr_state == Move_State.DYING:
		# timer += delta
		# if timer > (1.0/2.0):
			# %explode_SE.play()
			# timer -= (1.0/2.0)

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
			target = mc.get_encircle(player.transform.origin, encircleR, 250)#Target the mc's surrounding to circle them
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

func _on_un_targetting_timer_timeout() -> void:
	#once the timer finishes, change our current state back to circling.
	for x in can_collide:
		if x:
			curr_state = Move_State.CIRCLING
			return
	if !clone:
		fading_out()
	$JesterDashTrail.emitting = false

func fading_out() -> void:
	$AnimationPlayer.play("fade_out")
	curr_state = Move_State.FADED
	target = self.position

func _on_dash_timer_timeout() -> void:
	#Once the timer runs out, go dash!
	if !is_dead:
		go = true
		$JesterDashTrail.emitting = true

func is_dashing() -> bool:
	return dashing

#This uses last_vel instead of current vel, thats important
func calc_momentum() -> float:
	return mass * last_vel

#If this is a clone, this instead destroys the node
func spawn_clones() -> void:
	
	get_parent().play_anim(0,"Spin and spin, split to three, I have 2 twins, which one is me?!")
	#Clones should differ very very slightly from parent
	#Maybe a different animation speed?
	if (!clone and !is_dead):
		damage_till_clones += 15
		# print(damage_till_clones)
		var dist_from_center = 250
		var n : int = 3
		children_clones += n - 1
		var main_num = randi_range(0,n-1)
		for i in range(n):
			if i == main_num:
				self.set_position((MAP_CENTER) + Vector2.UP.rotated(deg_to_rad(360 * (i/float(n)))) * dist_from_center)
				self.curr_state = Move_State.CIRCLING
				self.encircleR = 360 * (i/float(n))
				can_collide = [true,true,true,true]
				$AnimationPlayer.play("fade_in")
			else:
				var lguy = baby_boy.instantiate()
				lguy.player = player
				lguy.clone = true
				lguy.curr_state = Move_State.CIRCLING

				var name_guy = "littleguy" + str(i)
				lguy.set_name(name_guy)
				self.add_sibling(lguy)
				lguy.father = self

				lguy.health_component.max_health = 30
				lguy.health_component.current_health = 30
				children_list.append(lguy)
				lguy.set_position((MAP_CENTER) + Vector2.UP.rotated(deg_to_rad(360 * (i/float(n)))) * dist_from_center)
				lguy.encircleR = 360 * (i/float(n))
				lguy.find_children("AnimationPlayer", "AnimationPlayer", false)[0].play("fade_in")
	elif clone:
		if father:
			father.child_loss(self)
		self.queue_free()
	elif is_dead:
		pass

func child_loss(child: Node) -> void:
	children_list.erase(child)
	children_clones -= 1

func kill_those_kids(d: int) -> void:
	if (!clone and children_clones > 0):
		damage_till_clones -= d
		if (damage_till_clones <= 0):
			# print("killing those kids")

			get_parent().play_anim(1,"MY CLONES!!!! NOOOO!!!!")
			damage_till_clones = 0
			children_clones = 0
			for c in children_list:
				c.fading_out()

func die() -> void:
	kill_those_kids(int(damage_till_clones))

	get_parent().play_anim(1,"NOOOOOO THE JOKES ON ME!!!!!")
	$JesterDie.play()
	linear_velocity = Vector2.ZERO
	curr_state = Move_State.IDLE
	is_dead = true
	$JesterDashTrail.restart()
	$JesterDashTrail.set_emitting(false)
	$AnimationPlayer.play("die")

func fight_done() -> void:
	get_parent().jester_died()
	self.queue_free()

func set_fiora() -> void:
	get_parent().play_anim(2,"wait what.")
	$Drill.play()
	$WeakSpot.enable()
