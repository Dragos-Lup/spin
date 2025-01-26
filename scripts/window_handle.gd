extends Node2D
var twerk = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	twerk = twerk*.9
	$WindowHandle.set_rotation($WindowHandle.get_rotation() + twerk)
	

func _throwitback() -> void:
	twerk = .2


func _on_texture_button_focus_entered() -> void:
	$StartPic.visible = true
	$OptionsPic.visible = false
	$QuitPic.visible = false


func _on_texture_button_2_focus_entered() -> void:
	$StartPic.visible = false
	$OptionsPic.visible = true
	$QuitPic.visible = false


func _on_texture_button_3_focus_entered() -> void:
	$StartPic.visible = false
	$OptionsPic.visible = false
	$QuitPic.visible = true
