class_name SmokeEffect extends Node3D

signal smoke_destroyed

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

func emit_particles():
	gpu_particles_3d.emitting = true

func particles():
	return gpu_particles_3d
