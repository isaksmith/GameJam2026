extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var base_collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

@onready var spriteback: Sprite2D = %BackSprite2D
@onready var base_collision_polygon_back: CollisionPolygon2D = %BackCollisionPolygon2D

@onready var wheel_axis: Node2D = %FrontWheelAxis      # the car's axis marker
@onready var wheel_axisback: Node2D = %BackWheelAxis 
@onready var car_body: RigidBody2D = %CarRigidbody     # the chassis, for the joint's node_a

@onready var back_wheel_body: RigidBody2D = %BackWheel # the other physics body -- node_b for its own pin



var _extra_collision_polygons: Array[CollisionPolygon2D] = []
var _extra_collision_polygons_back: Array[CollisionPolygon2D] = []
var _pin_joint: PinJoint2D = null
var _pin_joint_back: PinJoint2D = null


func _ready() -> void:
	create_collider_from_drawn_shape()


func align_and_pin_to_axis() -> void:
	_pin_joint = _pin_body_to_axis(self, wheel_axis, _pin_joint)
	_pin_joint_back = _pin_body_to_axis(back_wheel_body, wheel_axisback, _pin_joint_back)
	car_body.set_deferred("freeze", false)

# Shared logic for pinning a wheel body to its axle marker on the chassis.
# Returns the (possibly newly-created) PinJoint2D so the caller can store it.
func _pin_body_to_axis(body: RigidBody2D, axis: Node2D, joint: PinJoint2D) -> PinJoint2D:
	if not body or not axis:
		return joint

	# The body's local origin (0,0) is always kept at the drawing's centroid
	# (see create_collider_from_drawn_shape below), so re-pinning the origin
	# to the axis is all that's needed to keep the image's center on the axis
	# -- including every time the shape gets redrawn, not just at startup.
	body.global_position = axis.global_position

	if joint == null:
		joint = PinJoint2D.new()
		# Set position AND node_a/node_b BEFORE adding to the tree. The physics
		# server bakes in the anchor point at whatever position the joint has
		# the moment it's registered (when it enters the tree / gets its
		# node_a & node_b) -- if we add it first and move it after, the
		# constraint stays pinned at the old (0,0) position forever, even
		# though the node visually shows the new position.
		joint.global_position = axis.global_position
		joint.node_a = car_body.get_path()
		joint.node_b = body.get_path()
		joint.disable_collision = true
		# Deferred: calling add_child() synchronously here can hit "parent node
		# is busy setting up children" if we're still inside the tree's initial
		# _ready() pass (e.g. two wheel bodies both trying to add a joint to
		# the same shared parent while that parent is still notifying its
		# children). Deferring runs it right after the current frame's setup.
		get_parent().call_deferred("add_child", joint)
	else:
		joint.global_position = axis.global_position

	return joint


func create_collider_from_drawn_shape() -> void:
	_rebuild_collider_for_wheel(self, sprite, base_collision_polygon, _extra_collision_polygons)
	_rebuild_collider_for_wheel(back_wheel_body, spriteback, base_collision_polygon_back, _extra_collision_polygons_back)

	# Re-pin both wheels. Local (0,0) is always each drawing's own centroid
	# now, so this is what keeps each image's center locked to its wheel axis,
	# on the first draw AND on every redraw after that (no more drift).
	align_and_pin_to_axis()


# Shared logic for turning a drawn sprite's opaque pixels into collision
# polygon(s) on a given wheel body. `extra_polys` is the per-wheel array that
# tracks any additional islands beyond the first, so front and back wheels
# each keep their own set instead of sharing one.
func _rebuild_collider_for_wheel(body: RigidBody2D, spr: Sprite2D, base_poly: CollisionPolygon2D, extra_polys: Array[CollisionPolygon2D]) -> void:
	if not body or not spr or not spr.texture or not base_poly:
		return

	var img: Image = spr.texture.get_image()
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img, 0.1)

	var rect := Rect2i(Vector2i.ZERO, img.get_size())
	var polygons: Array[PackedVector2Array] = bitmap.opaque_to_polygons(rect, 2.0)

	# Keep only islands that can actually form a polygon (drop stray pixels/noise)
	var valid_polygons: Array[PackedVector2Array] = []
	for p in polygons:
		if p.size() >= 3:
			valid_polygons.append(p)

	if valid_polygons.is_empty():
		return

	# Freeze while we rebuild so the physics solver doesn't fight us mid-edit
	body.freeze = true

	# 1. Combined centroid ACROSS EVERY ISLAND (area-weighted), instead of
	#    just the first detected polygon. This is what makes disconnected
	#    strokes work, and what makes "center of the drawing" mean the
	#    center of everything you drew, not just the first stroke found.
	var real_center: Vector2 = calculate_combined_centroid(valid_polygons)

	# 2. One CollisionPolygon2D per island, so every stroke gets a collider
	#    -- even disconnected ones -- instead of only the first island.
	_clear_extra_colliders(extra_polys)

	for i in range(valid_polygons.size()):
		var raw_vertices := valid_polygons[i]
		var centered_vertices := PackedVector2Array()
		for vertex in raw_vertices:
			centered_vertices.append(vertex - real_center)

		var target_poly: CollisionPolygon2D
		if i == 0:
			target_poly = base_poly
		else:
			target_poly = base_poly.duplicate()
			body.add_child(target_poly)
			extra_polys.append(target_poly)

		target_poly.polygon = centered_vertices
		target_poly.disabled = false
		# The collider must sit exactly at the body's own origin -- any leftover
		# position on this node (from manually placing a shape in the editor)
		# would make it orbit around the body origin instead of spinning in place.
		target_poly.position = Vector2.ZERO
		target_poly.rotation = 0.0

	# 3. Realign the sprite so the texture still lines up with the new colliders.
	# NOTE: this offset math assumes the sprite draws centered on its node
	# origin -- force it here so a stray Inspector setting can't break the pivot.
	spr.centered = true
	spr.position = Vector2.ZERO
	spr.rotation = 0.0
	var half_texture_size: Vector2 = img.get_size() / 2.0
	spr.offset = half_texture_size - real_center

	body.set_deferred("freeze", false)


func _clear_extra_colliders(extra_polys: Array[CollisionPolygon2D]) -> void:
	for poly in extra_polys:
		poly.queue_free()
	extra_polys.clear()


# Precise Gauss/Shoelace centroid, combined across all polygon islands
# (area-weighted average, so bigger strokes count more than tiny specks)
func calculate_combined_centroid(polygons: Array[PackedVector2Array]) -> Vector2:
	var total_area := 0.0
	var weighted_centroid := Vector2.ZERO

	for verts in polygons:
		var area := 0.0
		var centroid := Vector2.ZERO
		var count := verts.size()
		for i in range(count):
			var p1 = verts[i]
			var p2 = verts[(i + 1) % count]
			var factor = (p1.x * p2.y) - (p2.x * p1.y)
			area += factor
			centroid.x += (p1.x + p2.x) * factor
			centroid.y += (p1.y + p2.y) * factor
		area *= 0.5
		if abs(area) < 0.0001:
			continue
		centroid /= (6.0 * area)

		weighted_centroid += centroid * abs(area)
		total_area += abs(area)

	if total_area < 0.0001:
		return Vector2.ZERO
	return weighted_centroid / total_area
