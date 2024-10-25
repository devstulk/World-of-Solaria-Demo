extends CharacterBody2D

@onready var anim_player: AnimatedSprite2D =  $anim_player
@onready var anim_weapon: AnimatedSprite2D =  $anim_weapon
@onready var anim_cart: AnimatedSprite2D =  $anim_cart
@onready var cart_collision: CollisionShape2D = $cart_collision
@onready var player_collision: CollisionShape2D = $player_collision
@onready var collision_sword_atk_down = $anim_weapon/sword_atk_down/collision_sword_atk_down
@onready var collision_sword_atk_up = $anim_weapon/sword_atk_up/collision_sword_atk_up
@onready var collision_sword_atk_left = $anim_weapon/sword_atk_left/collision_sword_atk_left
@onready var collision_sword_atk_right = $anim_weapon/sword_atk_right/collision_sword_atk_right


var speed: float = 200.0
var last_direction: String = "down"
var is_attack: bool = false
var in_cart: bool = false
var life: int = 5
var screen_size: Vector2
var hit_force: int = 3000

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_weapon.hide()
	anim_cart.hide()
	cart_collision.disabled = true
	screen_size = get_viewport_rect().size
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	# Toggle in and out cart.
	if Input.is_action_just_pressed("cart") and !is_attack:
		# Out cart.
		if in_cart:
			anim_cart.hide()
			in_cart = false
			speed = 200.0
			cart_collision.disabled = true
			player_collision.disabled = false
		# In cart.
		else:
			anim_cart.show()
			anim_player.play("cart_" + last_direction)
			anim_cart.play("cart_" + last_direction)
			in_cart = true
			speed = 400.0
			cart_collision.disabled = false
			player_collision.disabled = true
	
	if direction.x == 1:
		last_direction = "right"
	elif direction.x == -1:
		last_direction = "left"
	
	if direction.y == 1:
		last_direction = "down"
	elif direction.y == -1:
		last_direction = "up"
	
	if Input.is_action_pressed("attack") and !is_attack and !in_cart:
		is_attack = true
		anim_weapon.show()
		anim_player.play("attack_" + last_direction)
		anim_weapon.play("one_sword_" + last_direction)
		_toggle_atk_collision()
	elif direction and !is_attack:
		if in_cart:
			anim_player.play("cart_" + last_direction)
			anim_cart.play("cart_" + last_direction)
		else: 
			anim_player.play("move_" + last_direction)
	elif !is_attack and !in_cart:
		anim_player.play("idle_" + last_direction)
	
	# If is attacking not move player.
	if !is_attack:
		velocity = direction.normalized() * speed
		move_and_slide()
		
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)

func _on_anim_weapon_animation_finished():
	is_attack = false
	anim_weapon.hide()

func _check_player_is_died():
	if life > 0:
		return false
	else:
		return true
		

func _toggle_atk_collision():
	await get_tree().create_timer(0.2).timeout
	match last_direction:
		"down":
			collision_sword_atk_down.disabled = !collision_sword_atk_down.disabled
		"up":
			collision_sword_atk_up.disabled = !collision_sword_atk_up.disabled
		"left":
			collision_sword_atk_left.disabled = !collision_sword_atk_left.disabled
		"right":
			collision_sword_atk_right.disabled = !collision_sword_atk_right.disabled
	
	await get_tree().create_timer(0.1).timeout
	collision_sword_atk_right.disabled = true
	collision_sword_atk_left.disabled = true
	collision_sword_atk_up.disabled = true
	collision_sword_atk_down.disabled = true

func _on_sword_atk_body_entered(body):
	if body.is_in_group("enemy"):
		var collision_direction = body.global_position - global_position
		if abs(collision_direction.x) > abs(collision_direction.y):
			if collision_direction.x > 0:
				body._slime_receive_damage(Vector2(hit_force, 0))
			else:
				body._slime_receive_damage(Vector2(-hit_force, 0))
		else:
			if collision_direction.y > 0:
				body._slime_receive_damage(Vector2(0, hit_force))
			else:
				body._slime_receive_damage(Vector2(0, -hit_force))

func _player_receive_damage(direction: Vector2):
	life -= 1
	if _check_player_is_died():
		var main = find_parent("main")
		main.find_child("GUI")._show_game_over_menu()
		queue_free()
	else:
		velocity = direction
		move_and_slide()
		
		await create_tween().tween_property(self, 'modulate',Color(1, 0, 0), 0.05).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).finished
		create_tween().tween_property(self, 'modulate',Color(1, 1, 1), 0.05).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

