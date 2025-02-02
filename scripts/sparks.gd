extends AnimatedSprite2D
var clang:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_frame(6)
	pause()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if clang:
		if get_frame() == 6:
			pause()
			clang = false

func spark_play() -> void:
	set_frame(0)
	play()
	clang = true
