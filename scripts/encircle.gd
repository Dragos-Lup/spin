extends Polygon2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	#self.scale *= 1.05
	pass


func _on_timer_timeout() -> void:
	self.queue_free()
