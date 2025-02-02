extends TextureProgressBar

var stylebox
# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the value_changed signal
	self.value_changed.connect(_on_value_changed)
	stylebox = self.get_theme_stylebox("fill")
	
	# _on_value_changed(value)  # Update color immediately on ready

func _on_value_changed(new_value):
	if new_value > 100:
		stylebox.bg_color = Color.RED
	else:
		stylebox.bg_color = Color.GREEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(_delta: float) -> void:
# 	if self.value > 80:
		
# 		self.bg_color = Color.DARK_RED
# 	else:
# 		self.bg_color = Color.GREEN
