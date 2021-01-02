extends Area2D


export var SPEED := 50
export var init_dir := Vector2(-1, -1)
var direction

# Called when the node enters the scene tree for the first time.
func _ready():
	direction = init_dir


func _process(delta):
	position += SPEED * delta * direction.normalized()
