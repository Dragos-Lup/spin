extends RigidBody2D

const SPEED = 1000.0
const ACCELERATION = 500.0
const DASH_SPEED = 2000.0
const DASH_SLOW = .2
const C_DRAG = .5
@export var VOLUME_CURVE:Curve

@onready var spin_bar: ProgressBar = %SpinBar
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
const Encircle = preload("res://scenes/encirclePolygon.tscn")
var move_array: PackedVector2Array = PackedVector2Array()

var dash_start_time = 0

func _init() -> void:
	pass

func _physics_process(_delta: float) -> void:
	# Get the current input direction
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	# This is where the player wants to be moving. 
	var target_vel = direction * SPEED
	# print(target_vel)
	var vel_difference = (target_vel - linear_velocity) - C_DRAG * linear_velocity * 2
	
	#print(vel_difference)
	
	# Dash Mechanics
	if Input.is_action_just_pressed("dash"): 
		dash_start_time = Time.get_ticks_msec()
		state_machine.travel("jump")
	if Input.is_action_pressed("dash"):
		vel_difference = vel_difference * DASH_SLOW
	if Input.is_action_just_released("dash"):
		var chargetime = Time.get_ticks_msec() - dash_start_time
		if (chargetime) > 850:
			var dash_vector = (get_global_mouse_position() - global_position).normalized()
			apply_impulse(dash_vector * (DASH_SPEED * chargetime/1000))
			$Dash_SE.play()
			
	apply_central_force(vel_difference)

	$Spinning_SE.set_pitch_scale(linear_velocity.length()/950 + 1)
	spin_bar.value = linear_velocity.length() / 10


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
				#print(A,", ",B,", ",move_array[i], ", " , move_array[i+1])
				#print("INTERSECTED")
				var new_polygon = Encircle.instantiate()
				
				new_polygon.set_polygon(move_array.slice(i+1,-1))
				new_polygon.set_color(Color(1,0,0,.5))
				get_tree().root.add_child(new_polygon)
				break
			#else:
				#print("NOPE")
	

func ccw(A : Vector2,B : Vector2,C : Vector2):
	return (C.y-A.y) * (B.x-A.x) > (B.y-A.y) * (C.x-A.x)

# Checks if two line segements intersect at all
func intersect(A : Vector2,B : Vector2,C : Vector2,D : Vector2):
	return ccw(A,C,D) != ccw(B,C,D) and ccw(A,B,C) != ccw(A,B,D)

func _on_body_entered(_body: Node) -> void:
	print("YELLOW")
	if linear_velocity.length() >= SPEED*.18:
		$Clash_SE.play()
		$Clash_SE.set_volume_db(0+(linear_velocity.length()/450))
		print($Clash_SE.get_volume_db())
