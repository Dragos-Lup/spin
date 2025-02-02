extends Node2D

@export var max_health : int = 11
@export var current_health : int = 7
@export var isPlayer : bool = false #Is this a player health component. Not sure if we'll ever use this
@export var isBoss : bool = false #Is this a boss, try to keep this on.
@export var isClone : bool = false #Is this a clone

var boss_health_bar: TextureProgressBar #Just a reference to the healthbar

func Damage(amount: int):
	#Take some damage
	current_health -= amount
	if isBoss or isPlayer:
		boss_health_bar.value = current_health #If this is a boss set the healthbar too
		if isBoss:
			get_parent().kill_those_kids(amount)
	if isClone:
		Die()
	if current_health <= 0:
		Die() #If you are dead, die!
	if isPlayer:
		get_parent().took_damage()
	


	if current_health > max_health:
		current_health = max_health # We don't really want anyone to ever be over their max health

func Heal(amount: int):
	Damage(-amount) # Honestly put this in for the fun of it

func Die():
	if isPlayer:
		get_parent().die()
	if isClone:
		get_parent().fading_out()
	if isBoss:
		get_parent().die()
