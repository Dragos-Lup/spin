extends RigidBody2D

@export var SPEED : float = 1000.0

@export var DASH_SPEED : float = 2000.0
@export var DASH_SLOW : float = .001
@export var DASH_MAXTIME : float = 3000
@export var DASH_MINSPEED : float = 2000
@export var MOMENTUM_DIFF : float = 100

@export var VOLUME_CURVE:Curve
@onready var hitsparks: GPUParticles2D = $hitsparks
@onready var spin_bar: TextureProgressBar = %SpinBar
@onready var charge_bar: TextureProgressBar = %ChargeBar
@onready var encircle_bar: TextureProgressBar = %EncircleBar
@onready var health_component: Node2D = $HealthComponent
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var dash_effect: CPUParticles2D = $DashEffect

var is_dead = false

#Whether or not the player is dashing (for damage purposes)
var dashing = false

var is_encircle = false

var last_vel : float = 0
var maxEncircle : float = 4
var encircleTime : float = maxEncircle
var can_encircle : bool = true

# Holds the encircle shape
const Encircle = preload("res://scenes/helper_scenes/encirclePolygon.tscn")
# The array of past movements
var move_array: PackedVector2Array = PackedVector2Array()
# Holds the dash start time
var dash_start_time = 0

func _init() -> void:
	pass

func _physics_process(delta: float) -> void:
	last_vel = linear_velocity.length()
	# Get the current input direction
	if is_dead:
		return
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	# This is where the player wants to be moving. 
	# This is kinda hard to understand, but this is our influence, or how we want to be moving
	var target_vel = direction * SPEED
	# This is the difference between how we're moving now, and how we want to be moving.
	var vel_difference = (target_vel - linear_velocity)
	
	if dashing and linear_velocity.length() < DASH_MINSPEED:
		dashing = false
	if is_encircle:
		encircleTime -= delta
		encircle_bar.value = (encircleTime/maxEncircle) * 100
	if !can_encircle and !is_encircle:
		encircleTime += delta
		encircle_bar.value = (encircleTime/maxEncircle) * 100
		if encircleTime >= maxEncircle:
			can_encircle = true
			encircleTime = maxEncircle
	# Dash Mechanics
	if Input.is_action_just_pressed("dash"): 
		dash_start_time = Time.get_ticks_msec() #When did we start charging
		state_machine.travel("jump") #This is the cool little animation that plays neato!
	elif Input.is_action_pressed("dash"):
		vel_difference = (target_vel * DASH_SLOW - linear_velocity) #Slows the player down by "DASH_SLOW" amount
		var chargetime = Time.get_ticks_msec() - dash_start_time #How long did we charge for?
		charge_bar.value = (chargetime/DASH_MAXTIME) * 100
	if Input.is_action_just_pressed("encircle") and can_encircle:
		is_encircle = true
		can_encircle = false
		$GPUParticles2D.emitting = true
		pass
	if Input.is_action_just_released("encircle"):
		if is_encircle:
			reset_encircle()
	if Input.is_action_just_released("dash"):
		var chargetime = Time.get_ticks_msec() - dash_start_time #How long did we charge for?
		charge_bar.value = 0
		if (chargetime) > 850 and !is_dead:
			var dash_vector = (get_global_mouse_position() - global_position).normalized() #Where we going big boss
			apply_impulse(dash_vector * (DASH_SPEED * min(chargetime, DASH_MAXTIME)/1000)) #Applys the dash amount
			$Dash_SE.play() #Plays the dash sound effect
			dashing = true
			#var trans = Transform2D(rad_to_deg(get_angle_to(dash_vector)), self.position)
			#print(get_angle_to(get_global_mouse_position()))
			#$DashEffect.emit_particle(trans, Vector2.ZERO, Color.WHITE, Color.WHITE, 2)
			$DashEffect.set_rotation(get_angle_to(get_global_mouse_position()))
			$DashEffect.set_emitting(true)
			$DashEffect.restart()
	
	apply_central_force(vel_difference) # Applys regular movement effects (Or slowed from dashing)
	$Spinning_SE.set_pitch_scale(linear_velocity.length()/950 + 1)
	spin_bar.value = linear_velocity.length() / 10


#Should do this differently realistically but erm no
func set_healthbar(node : TextureProgressBar):
	health_component.boss_health_bar = node #The node we got send is the health bar, change the health_component accordingly
	#Set the max value and value of the health bar
	node.max_value = health_component.max_health 
	node.value = health_component.current_health

# Honestly bro ignore this shit
# Fundamentally, tracks player positioning and checks for "encircling"
func _on_location_timer_timeout() -> void:
	if !is_encircle:
		return
	var p : Vector2 = self.position
	move_array.append(p)
	if (move_array.size() > 40):
		reset_encircle()
	if (move_array.size() > 3):
		var A = move_array[move_array.size() - 1]
		var B = move_array[move_array.size() - 2]
		for i in range(0, move_array.size() - 1):
			if (intersect(A, B, move_array[i], move_array[i+1])):
				var new_polygon = Encircle.instantiate()
				
				new_polygon.find_child("CollisionPolygon2D").set_polygon(move_array.slice(i+1,-1))
				get_tree().root.add_child(new_polygon)
				reset_encircle()
				
				$Sparkle.play()
				break

func reset_encircle():
	$GPUParticles2D.restart()
	$GPUParticles2D.emitting = false
	move_array = PackedVector2Array()
	is_encircle = false
#Whenever a body touches our boy this goes
func _on_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	# if body.is_in_group("enemy") and linear_velocity.length() / 10 > 100:
	if body.is_in_group("enemy"):
		var e_dash = body.is_dashing()
		var p_m = calc_momentum()
		var e_m = body.calc_momentum()
		if (!dashing and !e_dash) or (dashing and e_dash):
			if p_m - e_m > MOMENTUM_DIFF:
				body.health_component.Damage(2)
				#print("Enem damage small")
			elif e_m - p_m > MOMENTUM_DIFF:
				self.health_component.Damage(2)
				#print("player damaged small")
			else:
				print("nothing change")
		elif dashing:
			body.health_component.Damage(5)
			#print("Enemy damage biggggggggg")
		elif e_dash:
			self.health_component.Damage(5)

			#print("player damage bigggggggggg")
		$Hit_SE.play()
		$hitsparks.emitting=true
		$hitsparks.restart()

		#$DampTimer.start()
		#linear_damp = 20
	if linear_velocity.length() >= SPEED*.03: #Lowkey unsure if this is neccessary
		_clash_effects(body)


# More math can ignore
func ccw(A : Vector2,B : Vector2,C : Vector2):
	return (C.y-A.y) * (B.x-A.x) > (B.y-A.y) * (C.x-A.x)

# Checks if two line segements intersect at all
func intersect(A : Vector2,B : Vector2,C : Vector2,D : Vector2):
	return ccw(A,C,D) != ccw(B,C,D) and ccw(A,B,C) != ccw(A,B,D)

# Visual effects for the clashing.
# Alex and Eric should touch this if they so desire.
func _clash_effects(body: Node2D) -> void:
	$Clash_SE.play()
	$Clash_SE.set_volume_db(-1+(linear_velocity.length()/550)) # Volume set for the clash

	var spark : GPUParticles2D = $Sparks #Grabs the sparks object and uses it
	var dir = (body.position - self.position).normalized() #finds the "point" of collision, really just an estimate
	var attack =  dir * 5
	
	spark.get_process_material().set_emission_shape_offset(Vector3(attack.x,attack.y,0)) #Sets the offset position to where we just clashed
	spark.get_process_material().set_direction(Vector3(-dir.x,-dir.y,0)) #Sets the direction similar to what we just did.
	spark.restart()


func _on_damp_timer_timeout() -> void:
	linear_damp = 0.05

func calc_momentum() -> float:
	return mass * last_vel

func die() -> void:
	is_dead = true
	dashing = false
	get_parent().play_death()
	state_machine.travel("die") #This is the cool little animation that plays neato!


func bringUpMenu() -> void:
	$deathsound.play()
	%ProfileAnimator.play_player_death()
	get_parent().player_dead = true

func took_damage() -> void:
	$Spinnerouch_SE.play()
