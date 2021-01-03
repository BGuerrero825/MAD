extends Node2D

export var message := "NULL"
export var completed := false
export var panel_location := 0  # panel location 0-3
export var game_timer := 30

var gauge_val := [0.0,0.0,0.0]
var gauge_decay := [0,0,0]
var gauge_light := []
var correct := [0,0,0]
var held_time := 0
# Inputs
var key = ['-','-','-']

onready var gauge := [get_node("gauge_0"),get_node("gauge_1"),get_node("gauge_2")]


# Called when the node enters the scene tree for the first time.
func _ready():
	assign_input()
	gauge_light.append(gauge[0].get_node("lights").get_children())
	gauge_light.append(gauge[1].get_node("lights").get_children())
	gauge_light.append(gauge[2].get_node("lights").get_children())
	#randomly assign a correct level for each gauge
	randomize()
	for i in range(3):
		correct[i] = floor(rand_range(5,12))

func _process(delta):
	for i in range(3):
		# update gauge decay if above 0
		if gauge_val[i] > 0:
			gauge_decay[i] += 1
		# if key pressed reset decay
		if Input.is_action_just_pressed(key[i]):
			$sounds/click_in.play()
			gauge_decay[i] = 0
			# button press
			gauge[i].get_node("button").frame = 1
			# if gauge not at max, increase value by half interval
			if gauge_val[i] < gauge_light[i].size() and not completed:
				gauge_val[i] += 0.5
				update_gauge(i, gauge_val[i], gauge_light[i])
		# button depress (linked to decay)
		if gauge_decay[i] == 5:
			gauge[i].get_node("button").frame = 0
		# if decay lasts 90 frames, decrease gauge value
		if gauge_decay[i] > 90 and not completed:
			gauge_val[i] -= 1
			gauge_decay[i] = 0
			update_gauge(i, gauge_val[i], gauge_light[i])
	#check win condition
	if not completed and (floor(gauge_val[0]) == correct[0] and floor(gauge_val[1]) == correct[1] and floor(gauge_val[2]) == correct[2]):
		held_time += 1
		$output_bar.set_bar(held_time * 100/60)
		#if held for full time, complete game
		if held_time > 60:
			completed = true
			$output_bar.set_bar(100)
			$output_bar.set_bar_color("green")
			$output_bar.set_message(message)
			$sounds/completed_beep.play()
	
func update_gauge(num, val, light):
	var color = 1 
	#flip colors to green if correct
	if floor(val) == correct[num]:
		color = 2
	#fill colors up to current fill level
	for i in range(floor(val)):
		light[i].frame = color
	for j in range(floor(val), light.size()):
		light[j].frame = 0

func assign_input():
	match panel_location:
		0:
			key[0] = '1'
			key[1] = '2'
			key[2] = '3'
		1:
			key[0] = 'E'
			key[1] = 'R'
			key[2] = 'T'
		2:
			key[0] = '6'
			key[1] = '7'
			key[2] = '8'
		3:
			key[0] = 'I'
			key[1] = 'O'
			key[2] = 'P'

	$gauge_0/button_label.text = key[0]
	$gauge_1/button_label.text = key[1]
	$gauge_2/button_label.text = key[2]
