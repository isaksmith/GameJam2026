extends Control
## HUD — the always-visible in-game overlay.
## For now it's just a Retry button that reloads the current level at any time —
## the heart of the redraw -> fail -> retry loop.

func _ready() -> void:
	# When Retry is clicked, ask the Game brain to reload the current level.
	$RetryButton.pressed.connect(Game.restart_level)
