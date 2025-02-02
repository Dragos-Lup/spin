extends Node2D

var MAX_FORCE : float
var MASS : float

func get_force(p, t, v, dt):
	var d = t - p
	var desired = d.normalized() * min(d.length() / dt, MAX_FORCE / MASS)
	var dtVelocity = desired - v
	var force = MASS * dtVelocity
	return force.limit_length(MAX_FORCE)


func get_encircle(loc, encircleR, R):
	return (loc) + Vector2.UP.rotated(deg_to_rad(encircleR)) * R


func set_mass(m):
	MASS = m


func set_max_force(f):
	MAX_FORCE = f
