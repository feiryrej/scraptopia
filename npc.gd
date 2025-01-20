extends CharacterBody2D

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

var path = [Vector2(917, 606), Vector2(917, 520), Vector2(917, 700)]  # Define path with vertical movement
var path_index = 0
var target_pos = path[0]  # Set initial target position

func _ready():
	randomize()

func _process(delta):
	if current_state == IDLE or current_state == NEW_DIR:
		$npc_spite.play("idle")  # Play idle animation when not moving
	elif current_state == MOVE and !is_chatting:
		move_along_path(delta)

func move_along_path(delta):
	if !is_chatting:
		update_direction()  # Update direction based on target position

		# Move towards the target position (only on the Y axis)
		var direction = (target_pos - position).normalized()
		position += direction * speed * delta
		
		# Update animation based on direction (up or down)
		if dir.y == -1:
			$npc_spite.play("n-walk")  # Walking upwards (north)
		elif dir.y == 1:
			$npc_spite.play("s-walk")  # Walking downwards (south)

		# If we're close to the target, switch to the next point in the path
		if position.distance_to(target_pos) < 5:  # Adjust threshold as needed
			path_index += 1
			if path_index >= path.size():
				path_index = 0  # Optionally, loop the path
			target_pos = path[path_index]  # Set the next target position

func update_direction():
	# Update the direction vector based on target position
	if target_pos.y > position.y:
		dir = Vector2.DOWN  # Move down (south)
	elif target_pos.y < position.y:
		dir = Vector2.UP    # Move up (north)

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
	$Timer.wait_time = choose([0.5, 1, 1.5])
	current_state = choose([IDLE, NEW_DIR, MOVE])

# Helper function for random choice (if needed for any behavior)
func choose(array):
	array.shuffle()
	return array.front()
