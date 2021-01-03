extends Node2D

export var message := "NULL"
export var completed := false
export var panel_location := 0  # panel location 0-3
export var game_timer := 30

# Inputs
var key := ['-','-','-','-','-','-','-','-']
var lock_state := [0,0,0,0,0,0,0,0]
var solution := [1,1,1,0,0,0,0,0]
var progress := 0
onready var lock := get_node("keys").get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	assign_input()
	randomize_solution()

func _process(delta):
	# key turns
	for i in range(8):
		if Input.is_action_just_pressed(key[i]):
			lock[i].frame = 1
			lock_state[i] = 1
		if Input.is_action_just_released(key[i]):
			lock[i].frame = 0
			lock_state[i] = 0
	#add progress if key turns matches the solution
	if lock_state == solution and not completed:
		progress += 1
		$output_bar.set_bar(progress/10)
	#randomize solution at 34% and 67% intervals
	if (progress == 340) or (progress == 670):
		randomize_solution()
		progress += 1
	#when game completed set progress to 100 and stop updating
	if progress > 990:
		completed = true
		$output_bar.set_bar(100)
		$output_bar.set_bar_color("green")
		$output_bar.set_message(message)

func randomize_solution():
	randomize()
	solution.shuffle()
	for i in range(8):
		if solution[i] == 1:
			lock[i].get_node("light").frame = 1
		else:
			lock[i].get_node("light").frame = 0
	

func assign_input():
	match panel_location:
		0:
			key[0] = '2'
			key[1] = '3'
			key[2] = 'q'
			key[3] = 'w'
			key[4] = 'a'
			key[5] = 's'
			key[6] = 'z'
			key[7] = 'x'
		1:
			key[0] = '4'
			key[1] = '5'
			key[2] = 'e'
			key[3] = 'r'
			key[4] = 'd'
			key[5] = 'f'
			key[6] = 'c'
			key[7] = 'v'
		2:
			key[0] = '7'
			key[1] = '8'
			key[2] = 'y'
			key[3] = 'u'
			key[4] = 'g'
			key[5] = 'h'
			key[6] = 'b'
			key[7] = 'n'
		3:
			key[0] = '9'
			key[1] = '0'
			key[2] = 'i'
			key[3] = 'o'
			key[4] = 'j'
			key[5] = 'k'
			key[6] = 'm'
			key[7] = 'l'

	$keys/key_0/button_label.text = key[0]
	$keys/key_1/button_label.text = key[1]
	$keys/key_2/button_label.text = key[2]
	$keys/key_3/button_label.text = key[3]
	$keys/key_4/button_label.text = key[4]
	$keys/key_5/button_label.text = key[5]
	$keys/key_6/button_label.text = key[6]
	$keys/key_7/button_label.text = key[7]
