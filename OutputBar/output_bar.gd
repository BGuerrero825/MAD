extends Sprite

const ORANGE = Color('fb9d28')
const GREEN = Color('6abe30')
const RED = Color('fa0404')
var current_percent = 0

func set_bar(percent):
	$load_bar.rect_size.x = int(86 * stepify(percent, 5)/100)
	current_percent = percent
	
func get_percent():
	return current_percent

func set_message(message):
	$output_message.text = message

func set_bar_color(color):
	if color == "ORANGE" or color == "orange":
		$load_bar.color = ORANGE
	elif color == "GREEN" or color == "green":
		$load_bar.color = GREEN
	elif color == "RED" or color == "red":
		$load_bar.color = RED
