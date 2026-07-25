extends Control
## PauseMenu — press Esc to pause/unpause. Overlays the game while paused
## with Resume / Restart / Menu.

func _ready() -> void:
	hide()  # hidden until the player pauses
	$Box/ResumeButton.pressed.connect(_resume)
	$Box/RestartButton.pressed.connect(_on_restart)
	$Box/MenuButton.pressed.connect(_on_menu)


func _unhandled_input(event: InputEvent) -> void:
	# "ui_cancel" is the Escape key by default (built in — no setup needed).
	# is_action_pressed() lives on the base InputEvent, so no type errors.
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_resume()
		else:
			_pause()


func _pause() -> void:
	show()
	get_tree().paused = true   # freeze the whole game


func _resume() -> void:
	hide()
	get_tree().paused = false  # unfreeze


func _on_restart() -> void:
	_resume()
	Game.restart_level()


func _on_menu() -> void:
	_resume()
	Game.go_to_menu()
