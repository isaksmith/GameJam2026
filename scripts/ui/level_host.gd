extends Node2D
## LevelHost — the gameplay container that stays alive while levels swap in and out.
##
## When this scene loads, it tells the Game brain "I'm the host", then asks it to
## load the first level. Everything else (retry, next level) happens through Game.

func _ready() -> void:
	# Hand the Game brain a reference to this container so it knows where to
	# put levels (into our "CurrentLevel" child).
	Game.host = self
	# Start the game at the first level in Game.LEVELS.
	Game.load_level(0)
