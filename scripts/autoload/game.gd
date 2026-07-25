extends Node
## Game — the global "brain" that runs the whole game flow.
##
## This is registered as an AUTOLOAD (Project Settings > Autoload), which means
## Godot keeps ONE copy of it alive for the entire game. Any script, anywhere,
## can call its functions by name, e.g.  Game.restart_level()

# The ordered list of levels. For now it points at your Level 2 so we can test.
# This is the ONE place levels are listed — add new level paths here as they're made.
const LEVELS: Array[String] = [
	"res://scenes/_dev/placeholder_level.tscn",
	"res://scenes/level_2.tscn",
]

# Which cart to spawn into each level. A placeholder ball for now;
# swap this for the real cart's path once it exists.
const CART_SCENE: String = "res://scenes/car.tscn"

# Where we currently are in the LEVELS list.
var current_index: int = 0

const MAIN_MENU: String = "res://scenes/ui/main_menu.tscn"
const LEVEL_HOST: String = "res://scenes/ui/level_host.tscn"

# A link to the live LevelHos.t scene (the gameplay container).
# LevelHost fills this in on itself when it loads (see level_host.gd).
var host: Node = null


# --- Coarse navigation: switch between menu and gameplay ---

func start_game() -> void:
	current_index = 0
	get_tree().change_scene_to_file(LEVEL_HOST)  # LevelHost then loads level 0

func go_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)

func quit_game() -> void:
	get_tree().quit()


# ---------------------------------------------------------------------------
# Loading levels
# ---------------------------------------------------------------------------

## Loads the level at LEVELS[index] into the host, spawns the cart, wires the goal.
func load_level(index: int) -> void:
	current_index = index

	# The empty Node2D inside LevelHost where the active level lives.
	var slot: Node = host.get_node("CurrentLevel")

	# Clear out the old level (and the cart inside it, since the cart is its child).
	# queue_free() removes a node safely at the end of the frame.
	for child in slot.get_children():
		child.queue_free()

	# Load the level file, make a live copy of it, and drop it into the slot.
	var level_scene: PackedScene = load(LEVELS[index])
	var level: Node = level_scene.instantiate()
	slot.add_child(level)

	# Put the cart in the level and hook up the win trigger.
	_spawn_cart(level)
	_wire_goal(level)


## The RETRY. Reloading the current level clears the crashed cart and starts fresh.
## This is the core of the redraw -> fail -> retry loop.
func restart_level() -> void:
	load_level(current_index)


## Advance to the next level, or finish the game if that was the last one.
func next_level() -> void:
	if current_index + 1 < LEVELS.size():
		load_level(current_index + 1)
	else:
		game_complete()


# ---------------------------------------------------------------------------
# Spawning the cart + detecting the win
# ---------------------------------------------------------------------------

## Instances the cart and places it at the level's PlayerSpawn marker.
func _spawn_cart(level: Node) -> void:
	var spawn: Marker2D = level.get_node("PlayerSpawn")
	var cart: Node2D = (load(CART_SCENE) as PackedScene).instantiate()
	# Add the cart as a CHILD OF THE LEVEL, so reloading the level removes the cart too.
	level.add_child(cart)
	cart.global_position = spawn.global_position


## Connects the level's Goal so we get told when a body enters it.
func _wire_goal(level: Node) -> void:
	var goal: Area2D = level.get_node("Goal")
	goal.body_entered.connect(_on_goal_entered)


## Called whenever ANY physics body enters the Goal area.
func _on_goal_entered(body: Node) -> void:
	# Only the cart counts. We check for the "cart" group so obstacles/debris don't win.
	print(body)
	if body.is_in_group("cart"):
		level_won()


# ---------------------------------------------------------------------------
# Outcomes  (connecting them to UI screens as we go)
# ---------------------------------------------------------------------------

func level_won() -> void:
	print("LEVEL WON!  ")
	host.get_node("UILayer/WinScreen").show_win()

func game_complete() -> void:
	print("GAME OVER! ")
