extends Control
## WinScreen — the overlay shown when the cart reaches the banana (the Goal).
## It pauses the game so the ball stops, and its buttons go to the next level or retry.

func _ready() -> void:
	hide()  # start invisible — we only show it when the player wins.

	# Connect the buttons to our functions here in code (so we don't have to
	# wire them up by hand in the editor). "pressed" is the signal a Button
	# sends when clicked; .connect() says "when that happens, call this function."
	$Box/NextButton.pressed.connect(_on_next_pressed)
	$Box/RetryButton.pressed.connect(_on_retry_pressed)


## Called by Game.level_won() the moment the cart enters the Goal.
func show_win() -> void:
	show()
	get_tree().paused = true  # freeze the whole game so the ball stops rolling.


func _on_next_pressed() -> void:
	hide()
	get_tree().paused = false  # unfreeze BEFORE loading the next level.
	Game.next_level()


func _on_retry_pressed() -> void:
	hide()
	get_tree().paused = false
	Game.restart_level()
