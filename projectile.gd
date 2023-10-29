extends Area2D

const LEFT = 0
const RIGHT = 1
const SPEED = 700

var direction 
var type = "projectile"

func init(player_position, player_direction):
	position = player_position
	
	if player_direction == LEFT:		
		direction = -1
		$AnimatedSprite2D.flip_h = true
		position.x -= 60
		position.y -= 15
		return
		
	if player_direction == RIGHT:
		direction = 1
		position.x += 15
		position.y -= 15

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ONE

	position.x += velocity.x * SPEED * delta * direction

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		$AnimatedSprite2D.visible = false
		$CollisionShape2D.disabled = true
		queue_free()
