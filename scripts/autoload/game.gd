extends Node
## Game — the global "brain" that runs the whole game flow.
##
## This is registered as an AUTOLOAD (Project Settings > Autoload), which means
## Godot keeps ONE copy of it alive for the entire game. Any script, anywhere,
## can call its functions by name, e.g.  Game.restart_level()

# The ordered list of levels. For now it points at your Level 2 so we can test.
# This is the ONE place levels are listed — add new level paths here as they're made.
const LEVELS: Array[String] = [
	"res://scenes/level_1.tscn",
	"res://scenes/level_2.tscn",
	"res://scenes/mushroom_level.tscn",
	"res://scenes/level_4.tscn",
]

# Which cart to spawn into each level. A placeholder ball for now;
# swap this for the real cart's path once it exists.
const CART_SCENE: String = "res://scenes/car.tscn"

# Where we currently are in the LEVELS list.
var current_index: int = 0

const MAIN_MENU: String = "res://scenes/ui/main_menu.tscn"
const LEVEL_HOST: String = "res://scenes/ui/level_host.tscn"

const DRAW_HUD: String = "res://scenes/ui/draw_hud.tscn"
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
	var canvas_layer: CanvasLayer = host.get_node("CanvasLayer")

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
	canvas_layer.delayed_trigger_camera_action()
	_wire_kill_zone(level)


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
	cart.add_to_group("cart")
	cart.add_wheels_to_group()
	#var frontwheel = cart.get_node(chassis/PinJoin2D_Front/frontWheel/CollisionPolygon2)
	# Add the cart as a CHILD OF THE LEVEL, so reloading the level removes the cart too.
	level.add_child(cart)
	cart.global_position = spawn.global_position

#func _spawn_drawHUD(level:Node) -> void:
	#var HUD: Node = (load(DRAW_HUD) as PackedScene).instantiate()
	#var parent_node = HUD.get_node("DrawHUD")
	#HUD.print_tree_pretty()
	#for child in parent_node.get_children():
		#parent_node.remove_child(child)
		#add_child(child)
	
## Connects the level's Goal so we get told when a body enters it.
func _wire_goal(level: Node) -> void:
	var goal: Area2D = level.get_node("Goal")
	goal.body_entered.connect(_on_goal_entered)


## Called whenever ANY physics body enters the Goal area.
func _on_goal_entered(body: Node) -> void:
	# Only the cart counts. We check for the "cart" group so obstacles/debris don't win.
	print(body)
	if body.is_in_group("cart"):
		body.setVictorySprite()
		level_won()


func _wire_kill_zone(level: Node) -> void:
	var killZone: Area2D = level.get_node("KillZone")
	if(is_instance_valid(killZone)):
		killZone.body_entered.connect(_on_kill_zone_entered)
	
func _on_kill_zone_entered(body: Node) -> void:
	
	if body.is_in_group("cart"):
		body.get_parent().on_kill()
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 3
		add_child(timer)
		timer.start()
		await timer.timeout
		timer.queue_free()
		restart_level()

# ---------------------------------------------------------------------------
# Outcomes  (connecting them to UI screens as we go)
# ---------------------------------------------------------------------------

func level_won() -> void:
	print("LEVEL WON!  ")
	host.get_node("UILayer/WinScreen").show_win()

func game_complete() -> void:
	print("GAME OVER! ")
