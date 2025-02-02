extends AnimationPlayer

@export var jester_sprites: Array[Texture2D]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func laughing() -> void:
	play("laughing")
	# print("THING PLAYED")
