extends Node2D

enum main_state {IDLE, JESTER, CHILD}

var curr_state = main_state.JESTER
var player_dead = false

@export var jester = preload("res://scenes/boss_parent.tscn")
@export var princely = preload("res://scenes/princely.tscn") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = %MainSpinner
	player.set_healthbar(%PlayerHealthBar)

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
	# get_tree().change_scene_to_file("res://scenes/menu.tscn")


func jester_died() -> void:
	%bossrushphase2.stop()
	print("fight done")
	%ProfileAnimator.play("show_won")
	%"Victory!".play()

func princely_died() -> void:
	print("princely died")
	start_jester()

func princely_lost() -> void:
	%music_controller.play("fade_out")

func start_jester() -> void:
	$bossrushphase2.play()
	%ProfileAnimator.boss = 1
	%ProfileAnimator.play_anim(3, "Your lame parlor tricks could never compare to my carnival spectacles!!")
	var j :Node2D= jester.instantiate()
	add_child(j)
	j.position = %spawn.position
	j.player = %MainSpinner
	j.set_healthbar(%BossHealthBar)
	j.set_profile_animator(%ProfileAnimator)
	
func start_princely() -> void:
	%ProfileAnimator.boss = 0
	%ProfileAnimator.play_anim(3, "Your Revo could never topple mine!")
	$bossrushphase1.play()
	var p :Node2D= princely.instantiate()
	add_child(p)
	p.position = %spawn.position
	p.player = %MainSpinner
	p.set_healthbar(%BossHealthBar)
	p.set_profile_animator(%ProfileAnimator)


func _on_timer_timeout() -> void:
	start_princely()
	# start_jester()

func play_anim(n,t):
	if player_dead:
		return
	%ProfileAnimator.play_anim(n,t)

func play_death():
	if player_dead:
		return
	%ProfileAnimator.play_death()
