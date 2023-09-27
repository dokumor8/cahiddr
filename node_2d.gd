extends Node2D

@onready var walk_marker = $WalkMarker
@onready var hero = $Hero
var cursor_state = "move"


func _input(event):
	if event.is_action_pressed("right_click"):
#		Array[Dictionary]
#		var parameters
		var space = get_world_2d().direct_space_state
		var parameters = PhysicsPointQueryParameters2D.new()
		parameters.position = get_global_mouse_position()
		parameters.collision_mask = 0x00000002
#		print(parameters.position)

#		var physics = PhysicsDirectSpaceState2D.new()
#		parameters.
		var intersect_objects = space.intersect_point(parameters, 4)
		print(intersect_objects)
		if (intersect_objects.is_empty()):
			walk_marker.global_position = get_global_mouse_position()
			walk_marker.show()
			hero.walk_to(walk_marker)
		else:
			var enemy_collider = intersect_objects[0]["collider"]
			hero.set_attack_target(enemy_collider)
			# TODO attack
#
#		if cursor_state == "move":
#
#		elif cursor_state == "attack":
#			print("attack")


#var walk_marker = $WalkMarker
#
#func _input(event):
#	if event.is_action_pressed("right_click"):
#		walk_marker.position = get_global_mouse_position()
#
#
#func _physics_process(delta):
#	velocity = position.direction_to(target) * speed
#	# look_at(target)
#	if position.distance_to(target) > 10:
#		move_and_slide()
#
#func _process(delta):
#	if Input.is_action_pressed("right_click"):
#		walk_marker.show()
#		walk_marker.position = get_global_mouse_position()
#
#	if ($Hero.position - walk_marker.position).


func _on_hero_end_movement():
	walk_marker.hide()

#
#func _on_unit_shoot_target(Bullet, direction, location):
#	var spawned_bullet = Bullet.instantiate()
#	add_child(spawned_bullet)
#	spawned_bullet.rotation = direction
#	spawned_bullet.position = location
#	spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
