extends Node2D

enum main_state {IDLE, JESTER, CHILD}

var curr_state = main_state.JESTER

@export var jester : Node2D
@export var princely : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var boss = get_tree().get_first_node_in_group("boss") #finds if this world has a boss
	#TODO: What if that doesn't work?
	boss.set_healthbar(%BossHealthBar) #Grabs that boss, and sets them to the healthbar
	boss.set_profile_animator(%ProfileAnimator)

	var player = %MainSpinner
	player.set_healthbar(%PlayerHealthBar)


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
	# get_tree().change_scene_to_file("res://scenes/menu.tscn")



func jester_died() -> void:
	print("fight done")
	start_princely()

func start_jester() -> void:
	print("Starting jester")

func start_princely() -> void:
	pass
