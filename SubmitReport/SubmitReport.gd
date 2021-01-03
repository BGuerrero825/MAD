extends Node2D


export var current_level := 0
export var message_prompt_list := []

const INDICATOR_OFFSET = 15

var active = false
var current_field = 0
var submit_field_idx = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/prompts.text = ""
	$ColorRect/answers.text = ""


func _process(delta):
	if visible and not active:
		active = true
		submit_field_idx = len(message_prompt_list) + 1
		
		print(message_prompt_list)
		# [FREQ: 4, SAT: 2, CODE: 4, SER: 1, ORD: 3]
		var answer_list = []
		var message_list_without_answers = []
		for message in message_prompt_list:
			answer_list.append(int(message[-1]))
#			message_list_without_answers.append(message[0:-1])
			var colon_pos = message.find(":")
			message_list_without_answers.append(message.left(colon_pos))
		
#		print(answer_list)
		
#		print(message_list_without_answers)
		for msg in message_list_without_answers:
			$ColorRect/prompts.text += msg + "\n"
			$ColorRect/answers.text += "0\n"
	
	elif active:
		if Input.is_action_just_released("ui_down"):
			$ColorRect/indicator_origin/offset.position.y += INDICATOR_OFFSET
		elif Input.is_action_just_released("ui_up"):
			$ColorRect/indicator_origin/offset.position.y -= INDICATOR_OFFSET

