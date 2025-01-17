extends Node2D

@export var max_health = 11
@export var current_health = 7
@export var isPlayer : bool = false
@export var isBoss : bool = false
# Called when the node enters the scene tree for the first time.

@onready var boss_health_bar: ProgressBar = %BossHealthBar

func _ready():
	if isBoss:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = current_health

func Damage(amount: int):
	
	current_health -= amount
	if isBoss or isPlayer:
		boss_health_bar.value = current_health

	if current_health <= 0:
		Die()
	if current_health > max_health:
		current_health = max_health

func Heal(amount: int):
	Damage(-amount)

func Die():
	print("This thing died!")
