extends Node2D

export var message := "NULL"
export var completed := false
export var panel_location := 0  # panel location 0-3
export var game_timer := 40

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
	if Input.is_action_just_pressed(key):
		$sounds/click_in.play()
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
		# button animation
		get_node("button").frame = 0
		$sounds/click_out.play()
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
		# on correct hit, play sounds and update progress
		elif current_charge == goal_charge or current_charge == goal_charge-1:
			completed = true
			$output_bar.set_bar(100)
			$output_bar.set_bar_color("green")
			$output_bar.set_message(message)
			$mid_beeps.play()
			$sounds/completed_beep.play()
		# reset current charge on release
		current_charge = 0

func assign_input():
	match panel_location:
		0:
			key = 'S'
		1:
			key = 'F'
		2:
			key = 'G'
		3:
			key = 'K'

	$button/button_label.text = key
