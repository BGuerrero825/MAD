extends ReferenceRect

var rotate_dial := 0  # -1, 0, 1
var can_rotate := true
var dial_position := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	# Input
	if Input.is_key_pressed(KEY_A):
		rotate_dial = -1
	elif Input.is_key_pressed(KEY_D):
		rotate_dial = 1
	else:
		rotate_dial = 0
	
	print(rotate_dial, " dial_pos: ", dial_position, " ", can_rotate)
	
	# Rotate the dial
	if rotate_dial != 0 and can_rotate:
		can_rotate = false
		
		dial_position = (dial_position + rotate_dial) % 5
		
	else:
		can_rotate = true

