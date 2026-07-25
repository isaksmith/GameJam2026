extends Control
## MainMenu — shows Tammy's title art. An invisible StartButton is placed over
## the drawn "Start" in the art; clicking it launches the game.

func _ready() -> void:
	$StartButton.pressed.connect(Game.start_game)
