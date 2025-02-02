extends Control

var p = false

func _input(event):
	if event.is_action_pressed("quit"):
		if !p:
			pause_it()
		else:
			unpause_it()
	

func _on_check_box_toggled(toggled_on:bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)

func _on_h_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(0, value)



func _on_option_button_item_selected(index:int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720))



func _on_pause_pressed() -> void:
	pause_it()

func pause_it():
	p = true
	show()

func unpause_it():
	p = false
	hide()


func _on_button_pressed() -> void:
	unpause_it()


func _on_button_2_pressed() -> void:
	get_tree().quit()
