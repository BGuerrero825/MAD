extends Node2D

signal submitted(correct_submission)

export var current_level := 0
export var message_prompt_list := []
var answer_list = []

export var active_ink_color := Color.red

const INDICATOR_OFFSET = 17

var active = false
var current_field = 0
var submit_field_idx = 0

onready var prompt_button_list = [$paper/p0, $paper/p1, $paper/p2, $paper/p3, $paper/p4, $paper/p5, $paper/submit_report]
onready var answer_button_list = [$paper/a0, $paper/a1, $paper/a2, $paper/a3, $paper/a4, $paper/a5, $paper/submit_report]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(delta):
	if visible and not active:
		active = true
		submit_field_idx = len(message_prompt_list)
		
		print(message_prompt_list)
		# [FREQ: 4, SAT: 2, CODE: 4, SER: 1, ORD: 3]
		var message_list_without_answers = []
		for message in message_prompt_list:
			answer_list.append(int(message[-1]))
#			message_list_without_answers.append(message[0:-1])
			var colon_pos = message.find(":")
			message_list_without_answers.append(message.left(colon_pos))
		
#		print(message_list_without_answers)
		for i in range(len(message_list_without_answers)):
			prompt_button_list[i].text = message_list_without_answers[i]
			answer_button_list[i].text = '0'
		prompt_button_list.resize(len(message_list_without_answers))
		answer_button_list.resize(len(message_list_without_answers))
		prompt_button_list.append($paper/submit_report)
		answer_button_list.append($paper/submit_report)
	
	elif active:
		# Color text
		for i in range(len(message_prompt_list)+1):
			if i != current_field:
				prompt_button_list[i].add_color_override("font_color", Color.black)
				answer_button_list[i].add_color_override("font_color", Color.black)
			else:
				prompt_button_list[i].add_color_override("font_color", active_ink_color)
				answer_button_list[i].add_color_override("font_color", active_ink_color)
		
		# Input
		if Input.is_action_just_released("ui_down") and current_field < submit_field_idx:
			current_field += 1
		elif Input.is_action_just_released("ui_up") and current_field > 0:
			current_field -= 1
		
		if current_field == submit_field_idx:
			if Input.is_action_just_released("submit_report"):
				var answers_match = true
				for i in range(len(message_prompt_list)):
					if answer_list[i] != int(answer_button_list[i].text):
						answers_match = false
				emit_signal("submitted", answers_match)
		else:  # in answer
			if Input.is_action_just_released("ui_right"):
				var new_value = min(5, int(answer_button_list[current_field].text) + 1)
				answer_button_list[current_field].text = str(new_value)
			elif Input.is_action_just_released("ui_left"):
				var new_value = max(1, int(answer_button_list[current_field].text) - 1)
				answer_button_list[current_field].text = str(new_value)
			

