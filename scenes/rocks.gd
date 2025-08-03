@tool
extends Node3D

var stone = preload("res://scenes/rock.tscn")

@export_range(0.0, 1.0, 0.05) var probability: float = 0.3
@export var defense_needed: float = 40.0
@export var destination_falling_rocks: Marker3D

@onready var spawning_rocks: Marker3D = $SpawningRocks
@onready var area_3d: Area3D = $Area3D
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $Area3D/AudioStreamPlayer3D

func _ready() -> void:
	update_area_position()

func spawn_rock():
	var random_spin = Vector3(
		randf_range(-5, 5),
		randf_range(-5, 5),
		randf_range(-5, 5)
	)
	var rock = stone.instantiate()
	add_child(rock)
	rock.global_transform.origin = spawning_rocks.global_transform.origin
	rock.angular_velocity = random_spin
	
	animate_rock_fall(rock)

func animate_rock_fall(rock: RigidBody3D):
	var distance = destination_falling_rocks.global_position.distance_to(spawning_rocks.global_position)
	var forward = -spawning_rocks.global_transform.basis.z
	var upward = Vector3.UP * distance
	var random_spread = Vector3(
		randf_range(-0.3, 0.3),  # small left/right variation
		randf_range(-0.1, 0.1),  # slight vertical variation
		randf_range(-0.3, 0.3)   # small forward/back variation
	)
	var randomized_forward = (forward + random_spread).normalized()
	var impulse = randomized_forward * distance * 1.5 + upward
	
	rock.apply_impulse(impulse)

func update_area_position():
	if destination_falling_rocks:
		area_3d.transform = destination_falling_rocks.transform

func should_event_fire() -> bool:
	return randf() < probability

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Train:
		if should_event_fire():
			var train: Train = body
			train.apply_damage(defense_needed, 0.1) # 10% less cargo integrity
			var total_rocks = randi_range(3, 5)
			audio_stream_player_3d.playing = true
			spawn_rocks_in_bursts(total_rocks)

func spawn_rocks_in_bursts(total_rocks: int) -> void:
	var rocks_spawned = 0
	while rocks_spawned < total_rocks:
		# spawn a random burst count, but don't exceed total needed
		var burst_count = randi_range(2, 4)
		burst_count = min(burst_count, total_rocks - rocks_spawned)

		for i in range(burst_count):
			spawn_rock()

		rocks_spawned += burst_count

		# Wait a random time before next burst (e.g., 0.1 to 0.3 seconds)
		var wait_time = randf_range(0.05, 0.2)
		await get_tree().create_timer(wait_time).timeout

func _on_area_3d_property_list_changed() -> void:
	update_area_position()
