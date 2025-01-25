extends Node2D

var MAX_FORCE : float
var MASS : float

func get_force(p, t, v, dt):
	var d = t - p
	var desired = d.normalized() * min(d.length() / dt, MAX_FORCE / MASS)
	var dtVelocity = desired - v
	var force = MASS * dtVelocity
	return force.limit_length(MAX_FORCE)


func get_encircle(loc, encircleR):
	return (loc) + Vector2.UP.rotated(deg_to_rad(encircleR)) * 250
