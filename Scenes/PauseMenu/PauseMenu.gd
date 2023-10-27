extends CanvasLayer


@export_file("*.tscn") var main_menu_path : String

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if $Control/ConfirmExit.visible:
			$Control/ConfirmExit.hide()
		elif $Control/ConfirmMainMenu.visible:
			$Control/ConfirmMainMenu.hide()
		else:
			InGameMenuController.close_menu()


func _on_ResumeBtn_pressed():
	InGameMenuController.close_menu()

func _on_RestartBtn_pressed():
	$Control/ConfirmRestart.popup_centered()

func _on_OptionsBtn_pressed():
	$Control/ButtonsContainer.visible = false
	$Control/OptionsMenu.visible = true

func _on_MainMenuBtn_pressed():
	$Control/ConfirmMainMenu.popup_centered()

func _on_ExitBtn_pressed():
	$Control/ConfirmExit.popup_centered()

func _on_ConfirmRestart_confirmed():
	InGameMenuController.close_menu()
	SceneLoader.reload_current_scene()

func _on_ConfirmMainMenu_confirmed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	InGameMenuController.close_menu()
	SceneLoader.load_scene(main_menu_path)

func _on_ConfirmExit_confirmed():
	get_tree().quit()

func _ready():
	if not OS.has_feature("web"):
		$Control/ButtonsContainer/ExitBtn.show()
	if not main_menu_path.is_empty():
		$Control/ButtonsContainer/MainMenuBtn.show()
