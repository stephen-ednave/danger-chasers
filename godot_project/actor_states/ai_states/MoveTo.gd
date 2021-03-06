extends State
class_name MoveToState

export var duration := 1.0
export var animation := "walk"
export var next_state := ""
export var go_to_target := true
export var closest_x_offset := true
export var x_offset := 0.0 # Based on what direction TARGET is facing
export var y_offset := 0.0
export var max_roam_radius := 600.0
export var min_roam_radius := 0.0
export var stagger := false
export var arrive_distance := 6.0
export var no_y := true
export var face_target := false
export var finish_on_arrive := false

onready var motion : MotionState = $Motion
onready var timer : Timer = $Timer
onready var wall_check_timer : Timer = $WallCheckTimer

var target_position : Vector2 = Vector2()
var start_position : Vector2 = Vector2()

var target

export var disable_obstacle_collider := false
export var disable_actor_collider := false
export var disable_player_stoppers_layer := false
var original_collision_mask_bit : bool
var original_actor_mask_bit : bool
var original_player_stoppers_layer_bit : bool


func enter(args := {}) -> void:
	.enter(args)
	motion.enter(args)
	
	owner.play_animation(animation)
	start_position = owner.global_position
	timer.start(duration)
	wall_check_timer.start()
	
	if args.has("target"):
		target = args["target"]
	
	if args.has("target_position"):
		target_position = args["target_position"]
	else:
		target_position = calculate_new_target_position()
	
	original_collision_mask_bit = owner.get_collision_mask_bit(Utilities.Layers.OBSTACLES)
	original_actor_mask_bit = owner.get_collision_mask_bit(Utilities.Layers.ACTORS)
	original_player_stoppers_layer_bit = owner.get_collision_layer_bit(Utilities.Layers.PLAYER_STOPPERS)
	
	if disable_obstacle_collider \
			or (args.has("disable_collider_in_state") and args["disable_collider_in_state"] == true):
		owner.set_collision_mask_bit(Utilities.Layers.OBSTACLES, false)
	if disable_actor_collider:
		owner.set_collision_mask_bit(Utilities.Layers.ACTORS, false)
	if disable_player_stoppers_layer:
		owner.set_collision_layer_bit(Utilities.Layers.PLAYER_STOPPERS, false)


func exit() -> void:
	.exit()
	motion.exit()
	timer.stop()
	wall_check_timer.stop()
	owner.set_collision_mask_bit(Utilities.Layers.OBSTACLES, original_collision_mask_bit)
	owner.set_collision_mask_bit(Utilities.Layers.ACTORS, original_actor_mask_bit)
	owner.set_collision_layer_bit(Utilities.Layers.PLAYER_STOPPERS, original_player_stoppers_layer_bit)


func _physics_process(delta : float) -> void:
	if go_to_target: 
		target_position = calculate_new_target_position()
	
	motion.move_to(target_position)
	
	if face_target and owner.target.get_target():
		var direction = owner.global_position.direction_to(owner.target.get_target().global_position)
		owner.set_rotation(Vector2(sign(direction.x), 0).angle())
	
	if finish_on_arrive and \
			(owner.global_position.distance_to(target_position) <= arrive_distance or \
			(no_y and abs(owner.global_position.x - target_position.x) <= arrive_distance)):
		finished(next_state)


func calculate_new_target_position() -> Vector2:
	var random_angle = randf() * 2 * PI
	var percent = randf()
	var random_radius = percent * (max_roam_radius - min_roam_radius) + min_roam_radius
	
	var base_position = start_position
	if go_to_target:
		if not target or not is_instance_valid(target):
			target = owner.target.get_target()
		if target:
			base_position = target.global_position
			if closest_x_offset:
				base_position.x -= x_offset * sign(target.global_position.x - owner.global_position.x)
			else:
				base_position.x += x_offset * sign(target.owner.look_direction.x)
	base_position.y += y_offset
	base_position += Vector2(cos(random_angle), sin(random_angle)) * random_radius
	
	if no_y:
		base_position.y = start_position.y
	
	return base_position


func take_damage(args := {}):
	if stagger:
		finished("Stagger", args)


func _on_Timer_timeout():
	finished(next_state, motion.get_exit_args())


func pause() -> void:
	.pause()
	if timer:
		timer.paused = true
		motion.pause()


func unpause() -> void:
	.unpause()
	if timer:
		timer.paused = false
		motion.unpause()


func _on_WallCheckTimer_timeout():
	if owner.is_on_wall():
		finished(next_state)
