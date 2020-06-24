extends MotionState
class_name DieState

signal died

onready var die_particles := $DieParticles

export var animation : String = "die"
export var queue_free_on_die := true
export var distance_multiplier : float = 3.0

const QUEUE_FREE_BUFFER := 5.0


func enter(args := {}) -> void:
	.enter()
	emit_signal("entered")
	owner.emit_signal("health_depleted", owner)
	owner.emit_signal("health_depleted_no_arg")
	
	owner.animation_player.play(animation)
	var direction : Vector2
	if args.has("direction"):
		direction = args["direction"]
		if args.has("force") and args.has("mass") and args.has("duration"):
			initialize(args["direction"], args["force"], args["mass"], args["duration"])
	die_particles.spawn(owner.global_position, owner.global_rotation, owner.global_scale, owner.get_parent(), direction)


func anim_finished(anim_name : String) -> void:
	owner.emit_signal("died", owner)
	emit_signal("died")
	if queue_free_on_die:
		owner.call_deferred("queue_free")


func initialize(direction : Vector2, force : float, initial_mass : int, duration : float) -> void:
	force *= distance_multiplier
	external.velocity = direction * force
	external.apply(direction, force, initial_mass)
	owner.set_rotation(direction.angle())