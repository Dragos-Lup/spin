extends RigidBody2D

const SPEED = 1000.0
var MAX_SPEED = 1000.0
const DASH_SPEED = 2000.0
const FRICTION = 20.0 ## calling this friction is evil, it's the value move_toward uses.
const BOUNCY = .8
const DASH_SLOW = .2

@onready var spin_bar: ProgressBar = %SpinBar
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
const Encircle = preload("res://scenes/encirclePolygon.tscn")
var move_array: PackedVector2Array = PackedVector2Array()

var dash_start_time = 0

func _init() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	var target_vel = (direction * SPEED).limit_length(MAX_SPEED) #This is how fast we want to go
	
	if Input.is_action_just_pressed("dash"): 
		dash_start_time = Time.get_ticks_msec()
		state_machine.travel("jump")
		MAX_SPEED *= DASH_SLOW
		#
	if Input.is_action_just_released("dash"):
		assert(MAX_SPEED == 200)  ## This will need to be removed in final build
		MAX_SPEED *= 1 / DASH_SLOW
		var chargetime = Time.get_ticks_msec() - dash_start_time
		if (chargetime) > 850:
			var dash_vector = (get_global_mouse_position() - global_position).normalized()
			apply_impulse(dash_vector * (DASH_SPEED * chargetime/1000))
	
	if (linear_velocity.length() < MAX_SPEED):
		apply_central_force(target_vel)


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
				print(A,", ",B,", ",move_array[i], ", " , move_array[i+1])
				print("INTERSECTED")
				var new_polygon = Encircle.instantiate()
				
				new_polygon.set_polygon(move_array.slice(i+1,-1))
				new_polygon.set_color(Color(1,0,0,.5))
				get_tree().root.add_child(new_polygon)
				break
			#else:
				#print("NOPE")
	

func ccw(A : Vector2,B : Vector2,C : Vector2):
	return (C.y-A.y) * (B.x-A.x) > (B.y-A.y) * (C.x-A.x)

func intersect(A : Vector2,B : Vector2,C : Vector2,D : Vector2):
	return ccw(A,C,D) != ccw(B,C,D) and ccw(A,B,C) != ccw(A,B,D)
