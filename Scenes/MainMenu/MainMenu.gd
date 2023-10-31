extends Control


@export_file("*.tscn") var game_scene_path : String
@export var options_packed_scene : PackedScene
@export var credits_packed_scene : PackedScene
@export var version_name: String = '0.0.0'

var animation_state_machine : AnimationNodeStateMachinePlayback
var options_scene
var credits_scene
var sub_menu

func load_scene(scene_path : String):
	SceneLoader.load_scene(scene_path)

func play_game():
	GameLog.game_started()
	SceneLoader.load_scene(game_scene_path)

func _open_sub_menu(menu : Control):
	menu.visible = true
	sub_menu = menu
	animation_state_machine.travel("OpenSubMenu")

func _close_sub_menu():
	if sub_menu == null:
		return
	animation_state_machine.travel("MainMenuOpen")
	sub_menu.visible = false
	sub_menu = null
	animation_state_machine.travel("MainMenuOpen")

func intro_done():
	animation_state_machine.travel("MainMenuOpen")

func _input(event):
	if animation_state_machine.get_current_node() == "Intro" and \
		(event is InputEventMouseButton or event is InputEventKey):
		intro_done()

func _setup_for_web():
	if OS.has_feature("web"):
		%ExitButton.hide()

func _setup_version_name():
	AppLog.version_opened(version_name)
	$"%VersionNameLabel".text = "v%s" % version_name

func _setup_play():
	if game_scene_path.is_empty():
		%PlayButton.hide()

func _setup_options():
	if options_packed_scene == null:
		%OptionsButton.hide()
	else:
		options_scene = options_packed_scene.instantiate()
		options_scene.hide()
		%OptionsContainer.call_deferred("add_child", options_scene)

func _setup_credits():
	if credits_packed_scene == null:
		%CreditsButton.hide()
	else:
		credits_scene = credits_packed_scene.instantiate()
		credits_scene.hide()
		if credits_scene.has_signal("end_reached"):
			credits_scene.connect("end_reached", _on_credits_end_reached)
		%CreditsContainer.call_deferred("add_child", credits_scene)

func _ready():
	_setup_for_web()
	_setup_version_name()
	_setup_options()
	_setup_credits()
	_setup_play()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")

func _on_play_button_pressed():
	play_game()

func _on_options_button_pressed():
	_open_sub_menu(options_scene)

func _on_credits_button_pressed():
	_open_sub_menu(credits_scene)
	credits_scene.reset()

func _on_exit_button_pressed():
	get_tree().quit()

func _on_credits_end_reached():
	_close_sub_menu()

func _on_back_button_pressed():
	_close_sub_menu()
