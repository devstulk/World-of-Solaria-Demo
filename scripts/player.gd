extends Area2D

@onready var anim = $AnimatedSprite2D

var speed: float = 200.0
var screen_size: Vector2
var last_direction: String = "down"

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		last_direction = "right"
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		last_direction = "left"
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		last_direction = "down"
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		last_direction = "up"
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		anim.play("move_" + last_direction)
	else:
		anim.play("idle_" + last_direction)
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
