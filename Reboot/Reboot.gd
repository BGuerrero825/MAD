extends Node2D

export var message := "NUM: 1"
export var completed := false
export var panel_location := 0

export var download_speed := 1

const COLOR_ORANGE = Color('fb9d28')
const COLOR_GREEN = Color('6abe30')
const COLOR_GREEN_LIGHT = Color('99e550')
const COLOR_RED = Color('fa0404')
const DARK_GRAY = Color('595652')

var key_yes = '-'
var key_no = '-'
var key_list = []  # populated in assign_input()
onready var key_label_list = [$ui/yes_key, $ui/no_key]
onready var key_sprite_list = [$ui/yes_button, $ui/no_button]

# Computer console format: [ [true_for_yes], ["message_string"] ]
var console_list := [ [true, "24952 CORRUPTED FILES DETECTED. PLEASE REBOOT THE COMPUTER SYSTEM. PRESS YES TO PROCEED"] ]

var console_idx := 0
var console_loading := false

var console_alert := false

var current_input := false

var download_txt_bar = "[center]- - - - - - - - - - - - - - - - - - -[/center]"
var download_txt_pass = "[center]SUCCESS[/center]"
var download_txt_fail = "[center][color=red]FAILURE - REVERTING[/color][/center]"

# Called when the node enters the scene tree for the first time.
func _ready():
	assign_input()
	$ui/monitor_text.text = console_list[console_idx][1]
	$ui/monitor_text.percent_visible = 0
	
	randomize()
	var new_console_challenges = [ [false, "PRESS YES TO NOT PROCEED"],
			[true, "PRESS YES TO ACTUALLY PROCEED"],
			[false, "DO NOT NOT PRESS NO"],
			[false, "DO NOT PRESS YES"],
			[true, "DOES THIS DAY OF THE WEEK END IN Y?"],
			[true, "DOES\n 23 PLUS 14 EQUAL 37?"],
			[false, "DOES\n 28 PLUS 12 EQUAL 30?"],
			[true, "DOES\n 28 PLUS 12 EQUAL 40?"] ]
	new_console_challenges.shuffle()
	new_console_challenges.resize(4)  # truncate challenge count
	console_list += new_console_challenges

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not completed and not console_loading and not console_alert:
		# Draw main display message challenge
		#$ui/monitor_text.text = console_list[console_idx][1]
		if $ui/monitor_text.percent_visible < 1.0:
			$ui/monitor_text.percent_visible += download_speed * delta
		
		# Input
		if Input.is_action_just_released(key_yes):
			current_input = true
			
			console_loading = true
			$load_timer.start()
			$ui/monitor_text.text = ""
		elif Input.is_action_just_released(key_no):
			current_input = false
			
			console_loading = true
			$load_timer.start()
			$ui/monitor_text.text = ""
	
	elif console_loading:
		$ui/load_text.percent_visible += download_speed * delta
		if $ui/load_text.percent_visible >= 0.99 or $ui/load_text.percent_visible <= 0.01:
			download_speed *= -1
	
	elif completed:
		pass
	
	# Color keys on presses, sound, and animate sprites
	for i in range(len(key_list)):
		if Input.is_action_just_pressed(key_list[i]):
			key_label_list[i].add_color_override("font_color", COLOR_GREEN)
			key_sprite_list[i].frame = 1
			$sounds/click_in.play()
		elif Input.is_action_just_released(key_list[i]):
			key_label_list[i].add_color_override("font_color", COLOR_ORANGE)
			key_sprite_list[i].frame = 0
			$sounds/click_out.play()


func _on_load_timer_timeout():
	console_alert = true
	console_loading = false
	$ui/load_text.percent_visible = 1
	
	if current_input == console_list[console_idx][0]:  # user chose correctly
		$ui/load_text.bbcode_text = download_txt_pass
		console_idx += 1
	else:  # user chose the wrong prompt
		$ui/load_text.bbcode_text = download_txt_fail
		console_idx = max(0, console_idx-1)  # don't go below 0
	
	$alert_timer.start()


func _on_alert_timer_timeout():
	$ui/load_text.bbcode_text = download_txt_bar
	$ui/load_text.percent_visible = 0.01
	console_alert = false
	$ui/monitor_text.percent_visible = 0
	if console_idx >= len(console_list):
		completed = true
		$ui/monitor_text.text = "SYSTEM SUCCESSFULLY REBOOTED. GOOD JOB."
		$ui/monitor_text.percent_visible = 1
	else:
		$ui/monitor_text.text = console_list[console_idx][1]


func assign_input():
	match panel_location:
		0:
			key_yes = 'z'
			key_no = 'x'
		1:
			key_yes = 'e'
			key_no = 't'
		2:
			key_yes = 'g'
			key_no = 'h'
		3:
			key_yes = 'k'
			key_no = 'l'
	
	# Update key_list
	key_list = [key_yes, key_no]
	
	# Update panel key indicators
	$ui/yes_key.text = key_yes
	$ui/no_key.text = key_no


