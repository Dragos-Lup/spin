extends AnimationPlayer

var boss = 0
@export var jester_sprites: Array[Texture2D]
@export var princely_sprites: Array[Texture2D]
@export var charlie_sprites: Array[Texture2D]

@export var fonts: Array[FontFile]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func laughing() -> void:
	play("laughing")
	# print("THING PLAYED")

func play_anim(num, text):
	var a
	if boss == 0:
		a = princely_sprites
	else:
		a = jester_sprites
	
	%ProfilePic.texture = a[num]
	%Dialogue.text = text
	laughing()
	# %Dialogue.theme_override_fonts.normal_font = fonts[boss]

func play_death():
	var a
	var text
	if boss == 0:
		a = princely_sprites
		text = "Heh, that’s what you get for using some two-bit Revo you got from your grandpa!"
	else:
		a = jester_sprites
		text = "BAHAHAHAHAHA I WIN AGAIN!!! I LOVE WINNING!!!"
	
	%ProfilePic.texture = a[0]
	%Dialogue.text = text
	laughing()
	# %Dialogue.theme_override_fonts.normal_font = fonts[boss]

func play_player_death():
	var a = randi_range(1,1000)
	if a == 1:
		%CharliePic.texture = charlie_sprites[2]
		%CharlieDialogue.text = "OH NO, MY THEY/THEM ASS GOT FOLDED!"
	else:
		%CharliePic.texture = charlie_sprites[3]
		%CharlieDialogue.text = "Gosh darn it... sorry grandpa...."
	%LostChecker.play("show_lost")

func play_player_win():
	var a = randi_range(1,1000)
	if a == 1:
		%CharliePic.texture = charlie_sprites[1]
		%CharlieDialogue.text = "Heh... if you had more pronouns maybe you would have stood a chance"
	else:
		%CharliePic.texture = charlie_sprites[1]
		%CharlieDialogue.text = "Yippee! I knew my grandpa's revo wouldn't let me down!"
	%LostChecker.play("show_won")
