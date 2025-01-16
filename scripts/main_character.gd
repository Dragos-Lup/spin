extends RigidBody2D

const SPEED = 1000.0
const DASH_SPEED = 2000.0
const DASH_SLOW = .001
const C_DRAG = .5
@export var VOLUME_CURVE:Curve

@onready var spin_bar: ProgressBar = %SpinBar
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

# Holds the encircle shape
const Encircle = preload("res://scenes/encirclePolygon.tscn")
# The array of past movements
var move_array: PackedVector2Array = PackedVector2Array()
# Holds the dash start time
var dash_start_time = 0

func _init() -> void:
	pass

func _physics_process(_delta: float) -> void:
	# Get the current input direction
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	# This is where the player wants to be moving. 
	# This is kinda hard to understand, but this is our influence, or how we want to be moving
	var target_vel = direction * SPEED
	# This is the difference between how we're moving now, and how we want to be moving.
	var vel_difference = (target_vel - linear_velocity)
	# Dash Mechanics
	if Input.is_action_just_pressed("dash"): 
		dash_start_time = Time.get_ticks_msec() #When did we start charging
		state_machine.travel("jump") #This is the cool little animation that plays neato!
	elif Input.is_action_pressed("dash"):
		vel_difference = (target_vel * DASH_SLOW - linear_velocity) #Slows the player down by "DASH_SLOW" amount
	if Input.is_action_just_released("dash"):
		var chargetime = Time.get_ticks_msec() - dash_start_time #How long did we charge for?
		if (chargetime) > 850:
			var dash_vector = (get_global_mouse_position() - global_position).normalized() #Where we going big boss
			apply_impulse(dash_vector * (DASH_SPEED * chargetime/1000)) #Applys the dash amount
			#TODO: Dashing should have a cap real talk, or scale logarithmically or something
			$Dash_SE.play() #Plays the dash sound effect
			
	apply_central_force(vel_difference) # Applys regular movement effects (Or slowed from dashing)
	$Spinning_SE.set_pitch_scale(linear_velocity.length()/950 + 1)
	spin_bar.value = linear_velocity.length() / 10

# Honestly bro ignore this shit
# Fundamentally, tracks player positioning and checks for "encircling"
func _on_location_timer_timeout() -> void:
	var p : Vector2 = self.position
	move_array.append(p)
	if (move_array.size() > 30):
		move_array.remove_at(0)
	if (move_array.size() > 3):
		var A = move_array[move_array.size() - 1]
		var B = move_array[move_array.size() - 2]
		for i in range(0, move_array.size() - 1):
			if (intersect(A, B, move_array[i], move_array[i+1])):
				var new_polygon = Encircle.instantiate()
				
				new_polygon.set_polygon(move_array.slice(i+1,-1))
				new_polygon.set_color(Color(1,0,0,.5))
				get_tree().root.add_child(new_polygon)
				break
	
# More math can ignore
func ccw(A : Vector2,B : Vector2,C : Vector2):
	return (C.y-A.y) * (B.x-A.x) > (B.y-A.y) * (C.x-A.x)

# Checks if two line segements intersect at all
func intersect(A : Vector2,B : Vector2,C : Vector2,D : Vector2):
	return ccw(A,C,D) != ccw(B,C,D) and ccw(A,B,C) != ccw(A,B,D)


func _on_body_entered(body: Node2D) -> void:
	if linear_velocity.length() >= SPEED*.03: #Lowkey unsure if this is neccessary
		_clash_effects(body)


# Visual effects for the clashing.
# Alex and Eric should touch this if they so desire.
func _clash_effects(body: Node2D) -> void:
	$Clash_SE.play()
	$Clash_SE.set_volume_db(0+(linear_velocity.length()/450)) # Volume set for the clash

	var spark : GPUParticles2D = %Sparks #Grabs the sparks object and uses it
	var dir = (body.position - self.position).normalized() #finds the "point" of collision, really just an estimate
	var attack =  dir * 5
	
	
	spark.get_process_material().set_emission_shape_offset(Vector3(attack.x,attack.y,0)) #Sets the offset position to where we just clashed
	spark.get_process_material().set_direction(Vector3(-dir.x,-dir.y,0)) #Sets the direction similar to what we just did.
	spark.restart()
