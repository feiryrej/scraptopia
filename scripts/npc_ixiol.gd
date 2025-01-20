extends CharacterBody2D

@export var dialogue : Dialogue

const speed = 20
var current_state = SIDE_LEFT

var dir = Vector2.LEFT
var start_pos

var is_roaming = true
var is_chatting = false

var player
var player_in_dialogue_zone = false

var last_direction = "w"

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

var path = [Vector2(13, -256), Vector2(-30, -256), Vector2(30, -256)]
var path_index = 0
var target_pos = path[0]  # Set initial target position

func _ready():
	$Timer.start()
	randomize()


func _process(delta):
	if current_state == IDLE:
		$human_spr.play(last_direction + "-idle")
	elif current_state == MOVE and !is_chatting:
		move(delta)

	# Trigger change of direction if necessary
	if is_roaming:
		match current_state:
			IDLE:
				pass
			NEW_DIR:
				dir = choose([Vector2.LEFT, Vector2.RIGHT])
			MOVE:
				move(delta)
	
	if Input.is_action_just_pressed("interact"):
		is_roaming = false
		is_chatting = true
		$human_spr.play(last_direction + "-idle")
		
func move(delta):
	if !is_chatting:
		# Move towards the target position
		var direction_to_target = (target_pos - position).normalized()
		position += direction_to_target * speed * delta

		# Update animation based on movement direction
		if abs(direction_to_target.x) > abs(direction_to_target.y):  # Prioritize horizontal movement
			if direction_to_target.x > 0:
				$human_spr.play("e-walk")  # East (right)
				last_direction = "e"
			elif direction_to_target.x < 0:
				$human_spr.play("w-walk")  # West (left)
				last_direction = "w"
		elif abs(direction_to_target.y) > abs(direction_to_target.x):  # Prioritize vertical movement
			if direction_to_target.y > 0:
				$human_spr.play("s-walk")  # South (down)
				last_direction = "s"
			elif direction_to_target.y < 0:
				$human_spr.play("n-walk")  # North (up)
				last_direction = "n"

		print("Ixiol position:", position)

		# If we're close to the target, switch to the next point in the path
		if position.distance_to(target_pos) < 5:  # Adjust threshold as needed
			path_index += 1
			if path_index >= path.size():
				path_index = 0  # Optionally, loop the path
			target_pos = path[path_index]  # Set the next target position

# Commenting out the movement logic for now
# func move(delta):
# 	if !is_chatting:
# 		position += dir * speed * delta


func interact():
		print("Interacting with ", self.name)
		print("Roaming state before: ", is_roaming)
		DialogueManager.dialogue = dialogue
		DialogueManager.show_dialogue()
		await get_tree().create_timer(5.0).timeout
		resume_roaming()

func resume_roaming():
	is_chatting = false  # Allow NPC to move again after the dialogue ends
	is_roaming = true     # Resume roaming behavior
	print("Avalciel is roaming again")

func _on_dialogue_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_in_dialogue_zone = true
		is_roaming = false


func _on_dialogue_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_dialogue_zone = false
		is_roaming = true


# Commenting out the timer-based state changes for now
func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([1, 1.5, 2, 2.5])
	current_state = choose([IDLE, NEW_DIR, MOVE])

# Helper function to choose a random item from an array
func choose(array):
	array.shuffle()
	return array.front()
