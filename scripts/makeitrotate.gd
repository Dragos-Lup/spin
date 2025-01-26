extends Sprite2D
var rotatatron = 0
var rotatatronjr = 0
var spinning:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spinning:
		if rotatatronjr < 1.4:
			rotatatronjr+=rotatatron*delta
	else:
		rotatatronjr = rotatatronjr*.92
	self.set_rotation((self.get_rotation()+ rotatatronjr*.3))

func _on_texture_button_focus_entered() -> void:
	rotatatron = 1
	spinning = true
	print("Ohhh im focused")


func _on_texture_button_focus_exited() -> void:
	rotatatron = -1
	spinning = false
	print("Ohhh im unfocused")
	print(rotatatronjr)
