class_name DrawnColliderUtils
extends RefCounted

# Shared logic for turning a drawn sprite's opaque pixels into one or more
# clean collision polygons. Used by both rigid_body_2d.gd (debug car) and
# wheel.gd (real car) so there's a single place this logic lives.


# Traces a texture's opaque silhouette into simple polygons suitable for
# CollisionPolygon2D. Returns an empty array only if literally nothing
# could be traced (e.g. a fully blank texture).
static func trace_polygons_from_texture(texture: Texture2D) -> Array[PackedVector2Array]:
	if not texture:
		return []
	return trace_polygons_from_image(texture.get_image())


static func trace_polygons_from_image(img: Image) -> Array[PackedVector2Array]:
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img, 0.1)
	var rect := Rect2i(Vector2i.ZERO, img.get_size())

	# epsilon stays at 2.0 on every attempt -- never 0.0. Dropping to 0.0
	# hands the raw, un-simplified marching-squares contour straight to
	# CollisionPolygon2D, which is what causes "Convex decomposing failed!"
	# on certain pixel configurations (a known Godot engine quirk).
	var polygons: Array[PackedVector2Array] = bitmap.opaque_to_polygons(rect, 2.0)
	var valid_polygons: Array[PackedVector2Array] = _filter_valid(polygons)

	# Small/thin drawings can get simplified away entirely -- grow the
	# opaque mask (more area) and retry at the SAME epsilon, rather than
	# loosening simplification.
	if valid_polygons.is_empty():
		bitmap.grow_mask(2, rect)
		polygons = bitmap.opaque_to_polygons(rect, 2.0)
		valid_polygons = _filter_valid(polygons)

	# Last resort: tracing failed entirely. Fall back to a sanitized
	# convex hull of the opaque pixels so a collider still exists.
	if valid_polygons.is_empty():
		var hull := sanitize_convex_polygon(_convex_hull_from_bitmap(bitmap, rect))
		if hull.size() >= 3:
			valid_polygons.append(hull)

	return valid_polygons


static func _filter_valid(polygons: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var valid: Array[PackedVector2Array] = []
	for p in polygons:
		if p.size() >= 3:
			valid.append(p)
	return valid


static func _convex_hull_from_bitmap(bitmap: BitMap, rect: Rect2i) -> PackedVector2Array:
	var points := PackedVector2Array()
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			if bitmap.get_bit(x, y):
				points.append(Vector2(x, y))

	if points.size() < 3:
		return PackedVector2Array()

	return Geometry2D.convex_hull(points)


# Drops near-duplicate consecutive points and near-collinear "spike"
# points -- both are known to trip Godot's convex decomposer.
static func sanitize_convex_polygon(points: PackedVector2Array) -> PackedVector2Array:
	if points.size() < 3:
		return PackedVector2Array()

	var deduped := PackedVector2Array()
	for p in points:
		if deduped.is_empty() or deduped[deduped.size() - 1].distance_to(p) > 0.5:
			deduped.append(p)
	if deduped.size() > 1 and deduped[0].distance_to(deduped[deduped.size() - 1]) <= 0.5:
		deduped.remove_at(deduped.size() - 1)

	if deduped.size() < 3:
		return PackedVector2Array()

	var cleaned := PackedVector2Array()
	var n := deduped.size()
	for i in range(n):
		var prev: Vector2 = deduped[(i - 1 + n) % n]
		var cur: Vector2 = deduped[i]
		var next: Vector2 = deduped[(i + 1) % n]
		var cross: float = (cur - prev).cross(next - cur)
		if abs(cross) > 0.01:
			cleaned.append(cur)

	if cleaned.size() < 3:
		return PackedVector2Array()

	return cleaned


# Area-weighted centroid combined across every island, so multi-stroke
# drawings center on the drawing as a whole, not just the first island.
static func calculate_combined_centroid(polygons: Array[PackedVector2Array]) -> Vector2:
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
