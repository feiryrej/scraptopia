extends CharacterBody2D

@export var dialogue: Dialogue

const speed = 30
var current_state = IDLE

var dir = Vector2.DOWN  # Initial direction (downward)
var start_pos

var is_roaming = true
var is_chatting = false

var player
var player_in_dialogue_zone = false

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

var path = [Vector2(1117, 115), Vector2(1117, 80), Vector2(1117, 160)]
var path_index = 0
var target_pos = path[0]  # Set initial target position

var direction_timer : Timer

func _ready():
	$Timer.start()
	randomize()

	direction_timer = Timer.new()
	direction_timer.wait_time = 7.0  # Time interval before each change
	direction_timer.one_shot = false  # Repeat indefinitely
	direction_timer.connect("timeout", Callable(self, "_on_direction_timer_timeout"))
	add_child(direction_timer)
	direction_timer.start()  # Start the timer immediately

func _process(delta):
	if is_chatting:
		return

	match current_state:
		IDLE:
			# Randomize the idle animation direction
			# Change the idle animation based on the last direction
			if dir == Vector2.UP:
				$human_spr.play("n-idle")
			elif dir == Vector2.DOWN:
				$human_spr.play("s-idle")
			elif dir == Vector2.LEFT:
				$human_spr.play("w-idle")
			elif dir == Vector2.RIGHT:
				$human_spr.play("e-idle")
		NEW_DIR:
			pass
		MOVE:
			pass

	if Input.is_action_just_pressed("interact"):
		is_roaming = false
		is_chatting = true
		$human_spr.play("idle")

#func move_along_path(delta):
#	update_direction()  # Update direction based on target position

	# Move towards the target position
#	var direction = (target_pos - position).normalized()
#	position += direction * speed * delta

	# Update animation based on movement direction
#	if dir == Vector2.UP:
#		$human_spr.play("n-walk")
#	elif dir == Vector2.DOWN:
#		$human_spr.play("s-walk")
#	elif dir == Vector2.LEFT:
#		$human_spr.play("w-walk")
#	elif dir == Vector2.RIGHT:
#		$human_spr.play("e-walk")

	# If we're close to the target, switch to the next point in the path
#	if position.distance_to(target_pos) < 5:
#		path_index += 1
#		if path_index >= path.size():
#			path_index = 0  # Loop the path if at the end
#		target_pos = path[path_index]
#		current_state = IDLE  # Switch to IDLE before picking a new direction


func _on_direction_timer_timeout():
	# Randomly set the direction when the timer times out (every 5 seconds)
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	dir = directions[randi() % directions.size()]

	print("Tsuchiruz Idle Direction: ", dir)  # Debugging: Log randomized direction

	# Reset the timer's wait time if needed to simulate slowing down effect
	direction_timer.wait_time = randf_range(7.0, 15.0)  # Change wait time to vary the interval randomly (3 to 7 seconds)

func interact():
	DialogueManager.dialogue = dialogue
	DialogueManager.show_dialogue()
	await get_tree().create_timer(5.0).timeout
	resume_roaming()

func resume_roaming():
	is_chatting = false  # Allow NPC to move again after the dialogue ends
	is_roaming = true     # Resume roaming behavior

func _on_dialogue_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_in_dialogue_zone = true
		is_roaming = false

func _on_dialogue_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_dialogue_zone = false
		is_roaming = true

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([1.5, 2, 2.5])
	current_state = choose([IDLE, NEW_DIR, MOVE])

func choose(array):
	array.shuffle()
	return array.front()
