extends CharacterBody2D

var speed = 100

var player_state = "idle"


func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")

	# Reset direction if multiple inputs are detected
	if direction.x != 0 and direction.y != 0:
		direction = Vector2.ZERO

	# Prioritize horizontal movement over vertical
	elif direction.x != 0:
		direction = Vector2(direction.x, 0)
	elif direction.y != 0:
		direction = Vector2(0, direction.y)

	# Update player state based on direction
	if direction == Vector2.ZERO:
		player_state = "idle"
	else:
		player_state = "walking"

	velocity = direction * speed
	move_and_slide()

	_play_animation(direction)


func _play_animation(dir):
	# Match is like switch
	match player_state:
		"idle":
			$AnimatedSprite2D.play("idle")
		"walking":
			match dir:
				Vector2.UP:
					$AnimatedSprite2D.play("n-walk")
				Vector2.RIGHT:
					$AnimatedSprite2D.play("e-walk")
				Vector2.DOWN:
					$AnimatedSprite2D.play("s-walk")
				Vector2.LEFT:
					$AnimatedSprite2D.play("w-walk")
