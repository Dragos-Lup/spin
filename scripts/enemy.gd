extends RigidBody2D

@onready var health_component: Node2D = $HealthComponent
@onready var collision_shape: Node2D = $CollisionShape2D
@onready var mc: Node2D = $MovementComponent
@onready var player = %MainSpinner #It's important that literally nothing else in the scene is called one of these two things
@onready var follower = %follower #For testing
@onready var ray_casts = [$RayCasts/DLray, $RayCasts/ULray, $RayCasts/URray, $RayCasts/DRray]

enum Move_State {IDLE, TARGETING, CIRCLING}
var curr_state = Move_State.CIRCLING


@export var MAX_FORCE: float = 10
@export var CIRCLE_SPEED: float = 100

var can_collide = [true, true, true, true]
var target: Vector2 = Vector2(940,530)
var checkTarget: bool = true
var encircleR: float = 0.0


func _ready() -> void:
	setup()
	pass

func set_healthbar(node : ProgressBar):
	health_component.boss_health_bar = node #The node we got send is the health bar, change the health_component accordingly
	#Set the max value and value of the health bar
	node.max_value = health_component.max_health 
	node.value = health_component.current_health

func _physics_process(delta: float) -> void:
	if curr_state == Move_State.TARGETING:
		target = player.transform.origin
	if curr_state == Move_State.CIRCLING:
		target = mc.get_encircle(player.transform.origin, encircleR)
		follower.transform.origin = target #TODO: delete this later
		for i in range(4):
			if ray_casts[i].is_colliding() and can_collide[i]:
				can_collide[i] = false
				print("COLLIDED ", i)

	encircleR += delta * CIRCLE_SPEED
	if encircleR >= 360:
		encircleR = encircleR - 360
	
	if target:
		apply_central_force(mc.get_force(self.transform.origin, target, linear_velocity, delta))

	# USELESS STUFF DONT WORRY ABOUT IT I MIGHT NEED IT LATER

	# if checkTarget and randfn(0,1) > .5:
	#	print("BOOSTED")
	#	checkTarget = false
		# apply_impulse(((target - self.transform.origin)).normalized() * 5000)

	# p(target - self.transform.origin).orthogonal() + 
	# curr_state = Move_State.IDLE

func _on_boss_timer_timeout() -> void:
	checkTarget = true

func setup() -> void:
	mc.set_mass(self.mass)
	mc.set_max_force(MAX_FORCE)
