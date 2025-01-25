extends RigidBody2D

@onready var health_component: Node2D = $HealthComponent
@onready var collision_shape: Node2D = $CollisionShape2D
@onready var movement_component: Node2D = $MovementComponent
# Called when the node enters the scene tree for the first time.

enum Move_State {IDLE, TARGETING, CIRCLING}

var curr_state = Move_State.CIRCLING

@onready var player = %MainSpinner #It's important that literally nothing else in the scene is called one of these two things
@onready var follower = %follower #For testing
# @onready var ray_cast_2d: RayCast2D = $RayCast2D


var can_collide = [true, true, true, true]
@onready var ray_casts = [$RayCasts/DLray, $RayCasts/ULray, $RayCasts/URray, $RayCasts/DRray]

var target: Vector2 = Vector2(940,530)

var checkTarget: bool = true
var encircleR: float = 0.0

func set_healthbar(node : ProgressBar):
	health_component.boss_health_bar = node #The node we got send is the health bar, change the health_component accordingly
	#Set the max value and value of the health bar
	node.max_value = health_component.max_health 
	node.value = health_component.current_health

func _physics_process(delta: float) -> void:
	# shouldn't be moving at all.
	var force = Vector2.ZERO
	# if ray_cast_2d.is_colliding():
		# print("colliding")
	if curr_state == Move_State.TARGETING:
		target = player.transform.origin
	if curr_state == Move_State.CIRCLING:
		target = get_encircle(player.transform.origin)
		follower.transform.origin = target #TODO: delete this later
		for i in range(4):
			if ray_casts[i].is_colliding() and can_collide[i]:
				can_collide[i] = false
				print("COLLIDED ", i)
				
				
	if target:
		force = 30 * (target - self.transform.origin) - linear_velocity
	apply_central_force(force)

	# USELESS STUFF DONT WORRY ABOUT IT I MIGHT NEED IT LATER

	# if checkTarget and randfn(0,1) > .5:
	#	print("BOOSTED")
	#	checkTarget = false
		# apply_impulse(((target - self.transform.origin)).normalized() * 5000)

	# p(target - self.transform.origin).orthogonal() + 
	# curr_state = Move_State.IDLE

	encircleR += delta * 100
	if encircleR >= 360:
		encircleR = encircleR - 360
	# print(encircleR)

func _on_boss_timer_timeout() -> void:
	checkTarget = true
