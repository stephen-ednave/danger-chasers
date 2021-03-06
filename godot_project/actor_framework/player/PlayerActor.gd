extends Actor
class_name PlayerActor

onready var player_hud := $PlayerHUDLayer/BattleHUD
onready var activation_scanner : ActivationArea = $ActivationScanner
var job : Job


func _ready() -> void:
	set_process_input(false)
	activation_scanner.disable()
	
	yield(get_tree().create_timer(0.01), "timeout") # Give animation player time to play SETUP
	
	player_hud.initialize(self, icon)
	
	job = $StateMachine/Job.current_job
	player_hud.set_hotbars(job)
	
	yield(get_tree().create_timer(0.01), "timeout") # Prevents occasional crash from job not being declared

	PlayerManager.activate_skill("Dash")
	PlayerManager.activate_skill("BackflipKunaiThrow")
#	PlayerManager.activate_skill("ReinaHomingMissiles")
#	PlayerManager.activate_skill("SparrowHomingMissiles")
#	PlayerManager.activate_skill("LavaLauncher")


func initialize(_team : String = "", initial_target=null) -> void:
	.initialize()
	set_process_input(true)
	activation_scanner.enable()


func _input(event : InputEvent) -> void:
	if not input_enabled:
		return
	
	var state = state_machine.get_current_state()
	if state != state_machine.get_state("Die") and state != state_machine.get_state("Stagger") and state != state_machine.get_state("Cutscene"):
		if event.is_action_pressed("attack_2"):
			if stats.resources["Kunai"].check():
				state_machine.change_state("KunaiThrow")
				stats.resources["Kunai"].reduce_value(1)
				return
		
		for i in range(1, 9):
			var input_skill = "skill_" + str(i)
			if event.is_action_pressed(input_skill):
				var current_state = state_machine.get_current_state()
				if current_state.name == "Job":
					if not current_state.get_current_skill().attacks._can_cancel_animation:
						return
				if state_machine.get_state("Job").skill_ready(input_skill):
					state_machine.change_state("Job", {"input_key":input_skill})


func _on_LightAttack_attack_connected(parameters):
	stats.resources["Kunai"].add_value(1)
