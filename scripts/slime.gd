extends CharacterBody2D

@onready var anim_slime: AnimatedSprite2D = $anim_slime
@onready var set_direction_timer: Timer = $set_direction_timer

var speed: float = 80.0
var patrol: bool = false
var chasing: bool = false
var player = null
var last_direction: String = 'down'
var screen_size: Vector2
var life: int = 5
var hit_force: int = 3000

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if chasing:
		_chasing_player()
	
	_set_animation()
	
	move_and_slide()
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)

func _on_set_direction_timer_timeout():
	patrol = !patrol
	if patrol:
		var direction_x: int = _generate_random_direction()
		var direction_y: int = _generate_random_direction()
		
		match randi_range(0, 2):
			0:
				_set_direction(Vector2(direction_x, 0))
			1:
				_set_direction(Vector2(0, direction_y))
			2:
				_set_direction(Vector2(direction_x, direction_y))
	else:
		_set_direction(Vector2.ZERO)

func _set_direction(direction: Vector2):
	velocity.x = direction.x * speed
	velocity.y = direction.y * speed

func _generate_random_direction():
	return -1 if randi_range(0, 1) == 0 else 1 

func _on_detect_area_body_entered(body):
	if body.is_in_group("player"):
		set_direction_timer.stop()
		player = body
		chasing = true

func _chasing_player():		
	var direction: Vector2 = (player.global_position  - global_position)
	_set_direction(direction.normalized())

func _on_detect_area_body_exited(body):
	if body.is_in_group("player"):
		set_direction_timer.start()
		player = null
		chasing = false

func _set_animation():
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			anim_slime.play("move_right")
			last_direction = "right"
		elif velocity.x < 0:
			anim_slime.play("move_left")
			last_direction = "left"
	elif abs(velocity.x) < abs(velocity.y):
		if velocity.y > 0:
			anim_slime.play("move_down")
			last_direction = "down"
		elif velocity.y < 0:
			anim_slime.play("move_up")
			last_direction = "up"
	else:
		anim_slime.play("idle_" + last_direction)

func _check_slime_is_died():
	if life > 0:
		return false
	else:
		return true

func _on_hit_area_body_entered(body):
	if body.is_in_group("player"):
		var collision_direction = body.global_position - global_position
		if abs(collision_direction.x) > abs(collision_direction.y):
			if collision_direction.x > 0:
				body._player_receive_damage(Vector2(hit_force, 0))
			else:
				body._player_receive_damage(Vector2(-hit_force, 0))
		else:
			if collision_direction.y > 0:
				body._player_receive_damage(Vector2(0, hit_force))
			else:
				body._player_receive_damage(Vector2(0, -hit_force))

func _slime_receive_damage(direction: Vector2):
	life -= 1
	if _check_slime_is_died():
		find_parent("main").slime_count -= 1
		queue_free()
	else:
		velocity = direction
		move_and_slide()
		
		await create_tween().tween_property(self, 'modulate', Color(1, 0, 0), 0.05).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).finished
		create_tween().tween_property(self, 'modulate', Color(1, 1, 1), 0.05).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

