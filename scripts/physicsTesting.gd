extends RigidBody2D

var target: Vector2 = Vector2(500,500)
var t_check: bool = false
var start: Vector2

var MAX_SPEED: float = 800
var MAX_FORCE: float = 400
var SLOW_RADIUS: float = 100

var proportionalGain: float = 1.0
var integralGain: float = 0.0
var derivativeGain: float = 50
var errorLast: Vector2 = Vector2.ZERO
var valueLast: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _integrate_forces(_state):
	linear_velocity = linear_velocity.limit_length(MAX_SPEED)

func _physics_process(_delta: float) -> void:
	var force = Vector2.ZERO

	#if ray_cast_2d.is_colliding():
	#	print("colliding")


	target = get_viewport().get_mouse_position()

	var error = target - self.transform.get_origin()
	



	# var P = proportionalGain * error
	# var errorRoC = (error - errorLast)# / delta
	# errorLast = error
	# var valueRoC = self.transform.get_origin() - valueLast #/ delta
	# valueLast = self.transform.get_origin()
	# var D = derivativeGain * errorRoC
	# print(D)	
	# force = P + D
	#if target:
	#	force = seek(target)
	apply_central_force(force)
	# print(linear_velocity)

func seek(_seek_target: Vector2) -> Vector2:
	var force = 2
	var desired_speed = MAX_SPEED
	var distance = force.length()
	if distance < SLOW_RADIUS:
		desired_speed = map(distance, 0, SLOW_RADIUS, 0, MAX_SPEED)
	force = force.normalized() * desired_speed
	force = force - linear_velocity
	force = force.limit_length(MAX_FORCE)
	return force


func map(value: float, start1: float, stop1: float, start2: float, stop2: float) -> float:
	return start2 + (value - start1) * (stop2 - start2) / (stop1 - start1)
