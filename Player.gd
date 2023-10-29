extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const LEFT = 0
const RIGHT = 1

var sprite_direction = RIGHT
var hp = 10
var projectile_scene = load("res://projectile.tscn")
var player_position
var stun = false
var invincible = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$AnimatedSprite2D.play("idle")
	player_position = get_node("/root/PlayerPosition")
	player_position.value = position

func _physics_process(delta):
	handle_sprite_direction()
	
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if stun:
		if sprite_direction == RIGHT:
			direction = -1
		else:
			direction = 1
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Spawn a projectile if shoot action
	if Input.is_action_just_pressed("shoot") and !stun:
		print("bang!")
		spawn_projectile()
	
	# Handle the sprite flip
	if !stun:
		set_sprite_direction(direction)
		
	move_and_slide()
	position = position.clamp(Vector2.ZERO, get_viewport_rect().size)
	player_position.value = position
	
func set_sprite_direction(input_direction):
	if input_direction < 0:
		sprite_direction = LEFT
	if input_direction > 0:
		sprite_direction = RIGHT

func handle_sprite_direction():
	if sprite_direction == LEFT:
		$AnimatedSprite2D.flip_h = true
	if sprite_direction == RIGHT:
		$AnimatedSprite2D.flip_h = false

func spawn_projectile():
	var p = projectile_scene.instantiate()
	p.init(position, sprite_direction)
	get_node("/root").add_child(p)


func _on_blob_player_hit(damage):
	if invincible:
		return
	
	hp -= damage
	if hp <= 0:
		handle_death()
		return
	
	handle_hit()
	print(hp)

func handle_hit():
	stun = true
	invincible = true
	$StunTimer.start()
	$BlinkingTimer.start()
	$InvincibilityTimer.start()
	$AnimatedSprite2D.visible = false
	velocity.y = -200

func handle_death():
	print("x _x")
	queue_free()
	

func _on_blinking_timer_timeout():
	$AnimatedSprite2D.visible = !$AnimatedSprite2D.visible


func _on_stun_timer_timeout():
	stun = false


func _on_invincibility_timer_timeout():
	invincible = false
	$BlinkingTimer.stop()
	$AnimatedSprite2D.visible = true
	$CollisionShape2D.disabled = true
	$CollisionShape2D.disabled = false
