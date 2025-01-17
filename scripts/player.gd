extends CharacterBody2D

# References
@onready var item_drop = load("res://scenes/item_drop.tscn")
@onready var human_spr = $human_spr
@onready var item_spr = $item_spr

@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound
@onready var drop_sound: AudioStreamPlayer2D = $DropSound

# Variables
var speed = 100
var movement_velocity = Vector2.ZERO  # Stores current velocity
var dir = Vector2.DOWN # Tracks the last movement direction
var tile_size = 16 # Change depending on our game's tile size
var movement_speed = 120 # Lower = slower, higher = faster
var is_moving = false
var movement_queue = Vector2.ZERO

var carrying_item = false
var drop_pos: Vector2
var items_in_range: Array = []

var male_arms_down_frames = preload("res://frames/male_arms_down.tres")
var male_arms_up_frames = preload("res://frames/male_arms_up.tres")
var female_arms_down_frames = preload("res://frames/female_arms_down.tres")
var female_arms_up_frames = preload("res://frames/female_arms_up.tres")

enum Gender { MALE, FEMALE}
var curr_gender = Gender.MALE

enum States { IDLE, MOVE }
var current_state = States.IDLE



func _ready():
	item_spr.hide()
	update_spritesheet()
	
	# wastes list     |     position   |      frame      |     scale
	spawn_item(Vector2(984, 615), Vector2i(0, 7), Vector2(0.62, 0.62))		# banana
	spawn_item(Vector2(807, 652), Vector2i(7, 4), Vector2(0.62, 0.62))		# plastic bag
	spawn_item(Vector2(1144, 696), Vector2i(1, 7), Vector2(0.62, 0.62))		# facemask
	spawn_item(Vector2(983, 455), Vector2i(2, 0), Vector2(0.62, 0.62))		# pencil
	spawn_item(Vector2(1159, 391), Vector2i(9, 0), Vector2(0.62, 0.62))		# wood plank
	spawn_item(Vector2(1062, 358), Vector2i(8, 4), Vector2(0.62, 0.62))		# rusty nail
	spawn_item(Vector2(1079, 280), Vector2i(1, 0), Vector2(1, 1))			# toxic pipe
	spawn_item(Vector2(1111, 183), Vector2i(1, 2), Vector2(0.62, 0.62))		# battery
	spawn_item(Vector2(1192, 169), Vector2i(6, 0), Vector2(1, 1))			# toxic barrel
	spawn_item(Vector2(1032, 151), Vector2i(1, 5), Vector2(1, 1))			# umbrella
	spawn_item(Vector2(1128, 72), Vector2i(3, 0), Vector2(0.62, 0.62))		# broken glass
	
	spawn_item(Vector2(1033, 42), Vector2i(7, 0), Vector2(0.62, 0.62))		# fuel container
	spawn_item(Vector2(999, -73), Vector2i(10, 4), Vector2(0.62, 0.62))		# wood
	spawn_item(Vector2(855, 56), Vector2i(4, 0), Vector2(0.62, 0.62))		# broken mirror
	spawn_item(Vector2(681, 25), Vector2i(11, 4), Vector2(0.62, 0.62))		# watermelon
	spawn_item(Vector2(614, -74), Vector2i(6, 5), Vector2(0.62, 0.62))		# stopwatch
	spawn_item(Vector2(537, -8), Vector2i(10, 5), Vector2(0.62, 0.62))		# feather
	spawn_item(Vector2(407, -70), Vector2i(9, 5), Vector2(0.62, 0.62))		# withered rose
	spawn_item(Vector2(456, -184), Vector2i(7, 5), Vector2(0.62, 0.62))		# broken helm
	spawn_item(Vector2(502, 118), Vector2i(5, 5), Vector2(0.62, 0.62))		# raw meat
	spawn_item(Vector2(761, -199), Vector2i(2, 6), Vector2(0.62, 0.62))		# broken shells
	spawn_item(Vector2(887, -246), Vector2i(0, 6), Vector2(0.62, 0.62))		# glass jar
	
	spawn_item(Vector2(1080, -184), Vector2i(3, 6), Vector2(0.62, 0.62))	# shards
	spawn_item(Vector2(1161, -266), Vector2i(7, 6), Vector2(0.62, 0.62))	# mask
	spawn_item(Vector2(1320, -281), Vector2i(4, 6), Vector2(0.62, 0.62))	# stone slab
	spawn_item(Vector2(967, -330), Vector2i(6, 6), Vector2(0.62, 0.62))		# leaf fan
	spawn_item(Vector2(423, 294), Vector2i(8, 3), Vector2(0.62, 0.62))		# pizza box
	spawn_item(Vector2(440, 504), Vector2i(8, 1), Vector2(0.62, 0.62))		# maple leaf
	spawn_item(Vector2(281, 425), Vector2i(6, 3), Vector2(0.62, 0.62))		# metal can
	spawn_item(Vector2(360, 602), Vector2i(1, 1), Vector2(0.62, 0.62))		# rotten fruits
	spawn_item(Vector2(183, 552), Vector2i(12, 4), Vector2(0.62, 0.62))		# map
	spawn_item(Vector2(72, 652), Vector2i(3, 4), Vector2(1, 1))				# black barrel
	
	spawn_item(Vector2(-69, 646), Vector2i(4, 0), Vector2(0.62, 0.62))		# broken bottle
	spawn_item(Vector2(-42, 521), Vector2i(4, 4), Vector2(0.62, 0.62))		# plastic bottle
	spawn_item(Vector2(-138, 408), Vector2i(4, 2), Vector2(0.62, 0.62))		# syringe
	spawn_item(Vector2(-71, 313), Vector2i(11, 2), Vector2(1, 1))			# rope
	spawn_item(Vector2(39, 232), Vector2i(0, 2), Vector2(0.62, 0.62))		# boots
	spawn_item(Vector2(-25, 138), Vector2i(2, 2), Vector2(1, 1))			# satellite
	spawn_item(Vector2(99, 119), Vector2i(7, 2), Vector2(0.62, 0.62))		# copper
	spawn_item(Vector2(69, -104), Vector2i(7, 1), Vector2(0.62, 0.62))		# leather
	spawn_item(Vector2(-88, -197), Vector2i(9, 2), Vector2(0.62, 0.62))		# glass flask
	spawn_item(Vector2(74, -281), Vector2i(0, 1), Vector2(0.62, 0.62))		# animal bone
	
	spawn_item(Vector2(-74, -311), Vector2i(9, 1), Vector2(0.8, 0.8))		# Log
	spawn_item(Vector2(-74, 58), Vector2i(12, 2), Vector2(0.4, 0.4))		# gloves


# for spawning wastes
func spawn_item(position: Vector2, frame_coords: Vector2i, scale_factor: Vector2):
	var new_item = item_drop.instantiate()
	print("Instantiating item_drop at position: ", position)

	new_item.position = position
	new_item.frame_coords = frame_coords
	new_item.scale = scale_factor

	var item_sprite = new_item.get_node("Sprite2D")
	if item_sprite:
		item_sprite.z_index = 0

	# writes scale_factor to new_item's metadata
	new_item.set_meta("initial_scale", scale_factor)
	get_parent().get_node("tm_virethariel").add_child(new_item)

	print("Item added to parent at position: ", new_item.position)


	
func _physics_process(delta):
	handle_state_transitions()
	perform_state_actions(delta)
	move_and_slide()



func handle_state_transitions():
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		current_state = States.MOVE
	else:
		current_state = States.IDLE



func perform_state_actions(delta):
		match current_state:
			States.MOVE:
				var horizontal_input = Input.get_axis("left", "right")
				var vertical_input = Input.get_axis("up", "down")
				
				dir = Vector2(horizontal_input, vertical_input).normalized()
				velocity = dir * speed
				
				if dir.x < 0:
					human_spr.play("w-walk")
					item_spr.flip_h = true
					item_spr.position.x = 8
				elif dir.x > 0:
					human_spr.play("e-walk")
					item_spr.flip_h = false
					item_spr.position.x = 8
				elif dir.y > 0:
					human_spr.play("s-walk")
				elif dir.y < 0:
					human_spr.play("n-walk")
			States.IDLE:
				velocity = Vector2.ZERO

				if dir.y > 0:
					human_spr.play("s-idle")
				elif dir.y < 0:
					human_spr.play("n-idle")
				elif dir.x > 0:
					human_spr.play("e-idle")
				elif dir.x < 0:
					human_spr.play("w-idle")



func update_spritesheet():
	if curr_gender == Gender.MALE:
		if carrying_item == true:
			human_spr.frames = male_arms_up_frames
		else:
			human_spr.frames = male_arms_down_frames
	if curr_gender == Gender.FEMALE:
		if carrying_item == true:
			human_spr.frames = female_arms_up_frames
		else:
			human_spr.frames = female_arms_down_frames



func _on_switch_gender_pressed():
	if curr_gender == Gender.MALE:
		curr_gender = Gender.FEMALE
		print(curr_gender)
	else:
		curr_gender = Gender.MALE
		print(curr_gender)
	update_spritesheet()



func _input(event):
	if event.is_action_pressed("pickupthrow"):
		if carrying_item:
			drop_item()
		else:
			if !items_in_range.is_empty():
				for item in items_in_range:
					if is_facing_item(item):
						pickup_item(item)
						break



func is_facing_item(item: Area2D) -> bool:

	var item_dir = (item.global_position - global_position).normalized()
	
	if dir == Vector2.RIGHT and item_dir.dot(Vector2.RIGHT) > 0.6:
		return true
	elif dir == Vector2.LEFT and item_dir.dot(Vector2.LEFT) > 0.6:
		return true
	elif dir == Vector2.UP and item_dir.dot(Vector2.UP) > 0.6:
		return true
	elif dir == Vector2.DOWN and item_dir.dot(Vector2.DOWN) > 0.6:
		return true
	
	return false



func adjust_item_z_index(item_sprite: Sprite2D, is_picking_up: bool):
	if item_sprite:
		item_sprite.z_index = -2
		human_spr.z_index = 0 if is_picking_up else 1
	else:
		print("Item sprite not found")



func pickup_item(item: Area2D):
	item.queue_free()
	carrying_item = true
	print("Carrying item: ", carrying_item)
	update_spritesheet()
	pickup_sound.play()

	item_spr.show()
	var item_sprite = item.get_node("Sprite2D")
	if item_sprite:
		item_spr.texture = item_sprite.texture
		item_spr.frame_coords = item_sprite.frame_coords
		print("Item texture and frame updated.")
	else:
		print("Error: Sprite2D not found in item.")

	# writes frame_coords and scale to item_spr metadata
	item_spr.set_meta("frame_coords", item_sprite.frame_coords)
	item_spr.set_meta("initial_scale", item_sprite.scale)
	#adjust_item_z_index(item_sprite, true)



func drop_item():
	item_spr.hide()

	var item = item_drop.instantiate()
	if item == null:
		print("Error: Item instantiation failed.")
		return

	print("Item instantiated successfully.")

	# adjust player position relative to parent node
	var adjusted_position = global_position - get_parent().position
	var player_tile_position = adjusted_position / tile_size
	var drop_tile_position = player_tile_position.floor() + dir
	var original_drop_position = (player_tile_position + dir) * tile_size + Vector2(tile_size / 2, tile_size / 2)

	# snapping logic based on direction
	var estimated_tile_position = player_tile_position.round()  # rounding the tile position to nearest grid
	var snapped_drop_tile_position = estimated_tile_position + dir

	var final_position = snapped_drop_tile_position * tile_size + Vector2(tile_size / 2, tile_size / 2)
	item.position = final_position

	# for debugging purposes
	print("Player global position: ", global_position)
	print("Parent position: ", get_parent().position)
	print("Adjusted player position: ", adjusted_position)
	print("Direction vector (dir): ", dir)
	print("Player tile position: ", player_tile_position)
	print("Estimated drop tile position (rounded): ", estimated_tile_position)
	print("Snapped drop tile position (final): ", snapped_drop_tile_position)
	print("Original drop position: ", original_drop_position)
	print("Final adjusted position: ", final_position)

	# retrieves the metadata from item_spr
	if item_spr.has_meta("frame_coords"):
		item.frame_coords = item_spr.get_meta("frame_coords")
	else:
		print("No frame_coords metadata found") # for debugging purposes

	# should supposedly get the scale from item_spr metadata
	if item_spr.has_meta("initial_scale"):
		item.scale = item_spr.get_meta("initial_scale")
	else:
		print("No initial_scale metadata found.") # for debugging purposes
		item.scale = Vector2(1, 1)

	get_parent().add_child(item)
	item.visible = true

	var item_sprite = item.get_node("Sprite2D")
	item_sprite.z_index = 0

	carrying_item = false
	update_spritesheet()
	drop_sound.play()



func _on_pickup_range_area_entered(area: Area2D):
	if area.is_in_group("item_drop"):
		items_in_range.append(area)
		print(items_in_range)



func _on_pickup_range_area_exited(area: Area2D):
	if area.is_in_group("item_drop"):
		items_in_range.erase(area)
		print(items_in_range)
