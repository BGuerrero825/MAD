extends Node2D

export var panel_location := 0  # panel location 0-3

# Inputs
var key = ['-','-','-']
var correct_number := 0
var correct_order := [0,0,0]
var completed := false
var hold = 0
var reset_timer := 60
var answered := 0
onready var light := [get_node("row_0/light_4"), get_node("row_0/light_2"), 
get_node("row_0/light_1"), get_node("row_1/light_4"), get_node("row_1/light_2"), 
get_node("row_1/light_1"), get_node("row_2/light_8"), get_node("row_2/light_4"), 
get_node("row_2/light_2"), get_node("row_2/light_1")]

# Called when the node enters the scene tree for the first time.
func _ready():
	assign_input()

func _process(delta):
	for i in range(3):
			# button press animation
			light[i].get_node("button").frame = 1 if Input.is_action_pressed(key[i]) else 0
	if reset_timer > 0:
		if reset_timer == 1:
			setup_problem()
		reset_timer -= 1
		
	elif hold > 0:
		if hold == 1:
			reset()
		hold -= 1
		
			
	else:
		for i in range(3):
			# if key pressed and light off, turn on
			if Input.is_action_just_pressed(key[i]) and light[i].frame == 0:
				# if part of solution, turn on light
				if correct_order[i] == 1:
					light[i].frame = 1
					#check whole solution and flash on win
					if light[0].frame == correct_order[0] and light[1].frame == correct_order[1] and light[2].frame == correct_order[2]:
						hold = 60
						add_progress(33)
						answered += 1
						if answered >= 3:
							completed = true
							set_progress(100)
						$happy_beep.play()
				#if not part of solution, reset
				else:
					$error_beep.play()
					reset()
					
func reset():
	correct_order = [0,0,0]
	# reset all lights to off
	for bulb in light:
		bulb.frame = 0
	reset_timer = 120
		
func setup_problem():
	# set up a new problem randomly
	randomize()
	correct_number = floor(rand_range(1,8))
	var additive = floor(rand_range(1,8))
	var sum = correct_number + additive
	# update solution array
	if correct_number - 4 >= 0:
		correct_number -= 4
		correct_order[0] = 1
	if correct_number - 2 >= 0:
		correct_number -= 2
		correct_order[1] = 1
	if correct_number - 1 >= 0:
		correct_order[2] = 1
	# update middle lights to new problem
	if additive - 4 >= 0:
		additive -= 4
		light[3].frame = 1
	if additive - 2 >= 0:
		additive -= 2
		light[4].frame = 1
	if additive - 1 >= 0:
		light[5].frame = 1
	# update bottom lights to new problem
	if sum - 8 >= 0:
		sum -= 8
		light[6].frame = 1
	if sum - 4 >= 0:
		sum -= 4
		light[7].frame = 1
	if sum - 2 >= 0:
		sum -= 2
		light[8].frame = 1
	if sum - 1 >= 0:
		light[9].frame = 1
	
#update progress bar at the bottom of the game, 86 is the length of the bar
func add_progress(percent):
	get_node("output_bar/load_bar").rect_size.x += int(86 * percent/100)
	
func set_progress(percent):
	get_node("output_bar/load_bar").rect_size.x = int(86 * percent/100)

func assign_input():
	match panel_location:
		0:
			key[0] = 'q'
			key[1] = 'w'
			key[2] = 's'
		1:
			key[0] = 'e'
			key[1] = 'r'
			key[2] = 't'
		2:
			key[0] = 'g'
			key[1] = 'y'
			key[2] = 'u'
		3:
			key[0] = 'i'
			key[1] = 'o'
			key[2] = 'p'

	$row_0/light_4/button_label.text = key[2]
	$row_0/light_2/button_label.text = key[1]
	$row_0/light_1/button_label.text = key[0]
	
