extends Node2D

export var panel_location := 0  # panel location 0-3

var current_charge := 0.0
var goal_charge := 0
onready var bars = get_node("panel/bars").get_children()

# Inputs
var key = '-'

# Called when the node enters the scene tree for the first time.
func _ready():
	assign_input()
	randomize()
	goal_charge = ceil(rand_range(14,21))
	print(goal_charge)
	bars[goal_charge].visible = true

func _process(delta):
	# charge if key pressed
	if Input.is_action_pressed(key):
		# button animation
		get_node("button").frame = 1
		#if first bar visible, reset all to invis
		if bars[0].visible:
			for bar in bars:
				bar.visible = false
			bars[goal_charge].visible = true
		current_charge += 0.1
	
	if Input.is_action_just_released(key):
		current_charge = ceil(current_charge)
		print(current_charge)
		# button animation
		get_node("button").frame = 0
		if current_charge > 22:
			current_charge = 22 
		# show charge amount on release
		for i in range(current_charge+1):
			bars[i].visible = true
		#play sounds if too high or too low
		if current_charge < goal_charge-1:
			$low_beeps.play()
		elif current_charge > goal_charge:
			$high_beeps.play()
		#on correct hit, play sounds and update progress
		elif current_charge == goal_charge or current_charge == goal_charge-1:
			$mid_beeps.play()
			set_progress(100)
		# reset current charge on release
		current_charge = 0

#update progress bar at the bottom of the game, 86 is the length of the bar
func set_progress(percent):
	get_node("output_bar/load_bar").rect_size.x = int(86 * percent/100)

func assign_input():
	match panel_location:
		0:
			key = 's'
		1:
			key = 'f'
		2:
			key = 'h'
		3:
			key = 'k'

	$button/button_label.text = key
