extends RigidBody2D

@export var health_component: Node2D
@export var collision_shape: Node2D
# Called when the node enters the scene tree for the first time.

enum Move_State {IDLE, TARGETING, CIRCLING}

var curr_state = Move_State.CIRCLING

@onready var player = %MainSpinner
@onready var follower = %follower

var target: Vector2 = Vector2(940,530)

var checkTarget: bool = true
var encircleR: float = 0.0

func set_healthbar(node : ProgressBar):
	health_component.boss_health_bar = node #The node we got send is the health bar, change the health_component accordingly
	#Set the max value and value of the health bar
	node.max_value = health_component.max_health 
	node.value = health_component.current_health

func _physics_process(delta: float) -> void:
	var force = Vector2.ZERO

	if curr_state == Move_State.TARGETING:
		target = player.transform.origin
	if curr_state == Move_State.CIRCLING:
		target = get_encircle(player.transform.origin)
		follower.transform.origin = target
	if target:
		force = 10 * (target - self.transform.origin) - linear_velocity
	apply_central_force(force)
	if checkTarget and randfn(0,1) > 2400:
		print("BOOSTED")
		checkTarget = false
		apply_impulse(((target - self.transform.origin).orthogonal() + (target - self.transform.origin)).normalized() * 5000)
	# curr_state = Move_State.IDLE

	encircleR += delta * 50
	if encircleR >= 360:
		encircleR = 0.0
	print(encircleR)

func get_encircle(loc):
	return (loc) + Vector2.UP.rotated(deg_to_rad(encircleR)) * 100

func _on_boss_timer_timeout() -> void:
	checkTarget = true
