extends Node2D

var B = 0
var M = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	f(4)
	print(B)
	print(M)
	B = 0
	M = 0
	f(16)
	print(B)
	print(M)
	B = 0
	M = 0
	f(64)
	print(B)
	print(M)
	

func f(n):
	if n > 1:
		for i in range(15):
			f(n/4)
		for i in range(n*n):
			B += 1
			f(n/4)
	else:
		M += 1
