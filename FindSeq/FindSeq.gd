extends ReferenceRect

export var panel_location := 0  # panel location 0-3

# Randomize in _ready() to not be the same as solution
var sequence := [1,6,4,3,2,5]
var seq_pos = 0

# Light objects
onready var lights := [get_node("light1"), get_node("light2"), 
get_node("light3"), get_node("light4"), get_node("light5"), get_node("light6")]

# Inputs
var key_1 := '-'
var key_2 := '-'
var key_3 := '-'
var key_4 := '-'
var key_5 := '-'
var key_6 := '-'


# Called when the node enters the scene tree for the first time.
func _ready():
	assign_input()
	randomize()
	sequence.shuffle()
	
func _process(delta):
	if seq_pos < 6:
		button_logic(key_1, 1)
		button_logic(key_2, 2)
		button_logic(key_3, 3)
		button_logic(key_4, 4)
		button_logic(key_5, 5)
		button_logic(key_6, 6)

func button_logic(key, num):
		# check for correct seq on initial press
	if Input.is_action_just_pressed(key):
		# if correct button for position in sequence, light green and progess seq
		if num == sequence[seq_pos]:
			lights[num - 1].frame = 2
			seq_pos += 1
		# else reset sequence and change lights to off
		else:
			for light in lights:
				light.frame = 0
				seq_pos = 0
				
	# press button and light red if light not already green
	if Input.is_action_pressed(key):
		lights[num - 1].get_node("button").frame = 1
		if lights[num - 1].frame != 2:
			lights[num - 1].frame = 1
	# unpress button and unlight if light was red
	else:
		lights[num - 1].get_node("button").frame = 0
		if lights[num - 1].frame != 2:
			lights[num - 1].frame = 0
			
func assign_input():
	match panel_location:
		0:
			key_1 = '1'
			key_2 = '2'
			key_3 = 'q'
			key_4 = 'w'
			key_5 = 'a'
			key_6 = 's'
		1:
			key_1 = '4'
			key_2 = '5'
			key_3 = 'e'
			key_4 = 'r'
			key_5 = 'd'
			key_6 = 'f'
		2:
			key_1 = '7'
			key_2 = '8'
			key_3 = 'y'
			key_4 = 'u'
			key_5 = 'g'
			key_6 = 'h'
		3:
			key_1 = '9'
			key_2 = '0'
			key_3 = 'i'
			key_4 = 'o'
			key_5 = 'j'
			key_6 = 'k'