extends ActorManagedStateManager
class_name PlayerManagedStateManager

export var face_target_node_path : NodePath


func enable() -> void:
	if not actor:
		actor = PlayerManager.player
	.enable()

func disable() -> void:
	if not actor:
		actor = PlayerManager.player
	.disable()

func play_animation(anim_name : String) -> void:
	if not actor:
		actor = PlayerManager.player
	.play_animation(anim_name)

func face_actor(target_actor=null):
	if not actor:
		actor = PlayerManager.player
	if not target_actor:
		if face_target_node_path:
			target_actor = get_node(face_target_node_path)
	.face_actor(target_actor)

func enable_input() -> void:
	if not actor:
		actor = PlayerManager.player
	.enable_input()

func disable_input() -> void:
	if not actor:
		actor = PlayerManager.player
	.disable_input()

func enable_activation_scanner() -> void:
	if not actor:
		actor = PlayerManager.player
	actor.activation_scanner.enable()

func disable_activation_scanner() -> void:
	if not actor:
		actor = PlayerManager.player
	actor.activation_scanner.disable()

func show_player_hud() -> void:
	PlayerManager.show_player_hud()

func hide_player_hud() -> void:
	PlayerManager.hide_player_hud()
