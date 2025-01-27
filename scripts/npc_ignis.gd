extends CharacterBody2D

@export var dialogue : Dialogue

const speed = 20
var current_state = SIDE_BOTTOM

var dir = Vector2.DOWN  # Initial direction (downward)
var start_pos

var is_roaming = true
#var is_ignis_roaming = true
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

func _ready():
	$Timer.start()
	randomize()
#	DialogueManager.connect("dialogue_closed", self, "resume_roaming")
#	start_pos = position

func _process(delta):
	if current_state == IDLE or current_state == NEW_DIR:
		$human_spr.play("idle")  # Play idle animation when not moving
	elif current_state == MOVE and !is_chatting:
#		move_along_path(delta)
		move(delta)
	if is_roaming:
		match current_state:
			IDLE:
				pass
			NEW_DIR:
				dir = choose([Vector2.DOWN,Vector2.UP])
			MOVE:
				move(delta)
				
	if Input.is_action_just_pressed("interact"):
		is_roaming = false
		is_chatting = true
		$human_spr.play("idle")

func move(delta):
	if !is_chatting:
#		update_direction()  # Update direction based on target position

		# Move towards the target position (only on the Y axis, ignore X movement)
#		var direction = (target_pos - position).normalized()
#		position += direction * speed * delta
		var direction_to_target = (target_pos - position).normalized()
		position += direction_to_target * speed * delta
		
		# Update animation based on direction (up or down)
#		if dir.y == -1:
#			$human_spr.play("n-walk")  # Walking upwards (north)
#		elif dir.y == 1:
#			$human_spr.play("s-walk")  # Walking downwards (south)
#		if abs(direction_to_target.y) > abs(direction_to_target.x):  # Prioritize vertical movement
		if direction_to_target.y > 0:
			$human_spr.play("s-walk")  # South (down)
		elif direction_to_target.y < 0:
			$human_spr.play("n-walk")  # North (up)
			
		#print("Ignis position:", position)

		# If we're close to the target, switch to the next point in the path
		if position.distance_to(target_pos) < 5:  # Adjust threshold as needed
			path_index += 1
			if path_index >= path.size():
				path_index = 0  # Optionally, loop the path
			target_pos = path[path_index]  # Set the next target position

#func update_direction():
	# Update the direction vector based on target position
#	if target_pos.y > position.y:
#		dir = Vector2.DOWN  # Move down (south)
#	elif target_pos.y < position.y:
#		dir = Vector2.UP    # Move up (north)
#	if current_state == NEW_DIR:
#		dir = choose([Vector2.DOWN, Vector2.UP])
#		current_state = MOVE
		
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
	print("Ignis is roaming again")

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
	$Timer.wait_time = choose([1, 1.5, 2])
	current_state = choose([IDLE, NEW_DIR, MOVE])

func choose(array):
	array.shuffle()
	return array.front()
