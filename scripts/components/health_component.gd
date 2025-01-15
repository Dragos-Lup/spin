extends Node2D

@export var max_health = 11
@export var current_health = 7
# Called when the node enters the scene tree for the first time.

func Damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		Die()
	if current_health > max_health:
		current_health = max_health

func Heal(amount: int):
	Damage(-amount)

func Die():
	print("This thing died!")
