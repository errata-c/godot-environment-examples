extends Reference

var length = 1.0
var mass = 1.0
var imass = 1.0 / mass
var center = 0.25
var inertia = 1.0
var gravity = Vector2(0.0, 9.8)

# External torques to add in.
var torques = [0.0, 0.0]
var links = []

var PREV_POS = 0
var POS = 1
var VEL = 2
var ROT = 3
var PREV_ROT = 4
var AVEL = 5

var substeps = 5

func get_link_angle(l):
	return links[l][ROT] 

func get_link_angular_velocity(l):
	return links[l][AVEL]

func get_link_transform(l):
	return link_transform(links[l])

func set_torque(l, t):
	torques[l] = t

func reset(a1, a2, av1, av2):
	links = []
	for _i in range(2):
		links.push_back([
			Vector2(0.0,0.0), # Prev pos
			Vector2(0.0,0.0), # Pos
			Vector2(0.0,0.0), # Velocity
			0.0, # Rot
			0.0, # Prev rot
			0.0, # Angular vel
		])
	
	links[0][ROT] = a1
	links[1][ROT] = a2
	
	links[0][AVEL] = av1
	links[1][AVEL] = av2
	
	var p0 = left_rot(complex(a1))
	var p1 = left_rot(complex(a2)) * center + p0 * 0.5
	p0 = p0 * center
	
	links[0][POS] = p0
	links[1][POS] = p1

func solve(dt):
	var sdt = dt / substeps
	
	for _i in range(substeps):
		for j in range(2):
			var link = links[j]
			# Integrate position
			link[PREV_POS] = link[POS]
			link[VEL] += sdt * gravity * imass
			link[POS] += sdt * link[VEL]
			
			# Integrate rotation
			link[PREV_ROT] = link[ROT]
			link[AVEL] += sdt * (torques[j] / inertia)
			link[ROT] += link[AVEL] * sdt
		
		# Solve positions
		solve_joint_1()
		solve_joint_2()
		
		# Update state
		for j in range(2):
			var link = links[j]
			link[VEL] = (link[POS] - link[PREV_POS]) / sdt
			link[AVEL] = (link[ROT] - link[PREV_ROT]) / sdt
		
		# Solve velocities?

	torques = [0.0, 0.0]

# One or both of these functions are broken.
func solve_joint_1():
	var l1 = links[0]
	var form = link_transform(l1)
	
	var target = Vector2(0.0, 0.0)
	var joint = form.xform(Vector2(0.0, -center))
	var dpos = -(target - joint)
	
	var c = dpos.length()
	var n = dpos.normalized()
	
	var r1 = joint - form.origin
	var lt = r1.dot(left_rot(n))
	
	var w = imass + lt * lt / inertia
	
	var p = (-c / w) * n
	
	l1[POS] += p * imass
	l1[ROT] += r1.dot(left_rot(dpos)) / inertia

func solve_joint_2():
	var l1 = links[0]
	var l2 = links[1]
	
	var form1 = link_transform(l1)
	var form2 = link_transform(l2)
	
	var target = form1.xform(Vector2(0.0, center))
	var joint = form2.xform(Vector2(0.0, -center))
	
	var dpos = target - joint
	var c = dpos.length()
	var n = dpos.normalized()	
	var ln = left_rot(n)
	
	var r1 = target - form1.origin
	var r2 = joint - form2.origin
	
	var lt1 = r1.dot(ln)
	var lt2 = r2.dot(ln)
	
	var w1 = imass + lt1 * lt1 / inertia
	var w2 = imass + lt2 * lt2 / inertia
	
	var p = (-c / (w1 + w2)) * n
	
	l1[POS] += p * imass
	l2[POS] -= p * imass
	
	l1[ROT] += r1.dot(left_rot(dpos)) / inertia
	l2[ROT] -= r2.dot(left_rot(dpos)) / inertia

func link_transform(link):
	return Transform2D(link[ROT], link[POS])

func complex(a):
	return Vector2(cos(a), sin(a))

func complex_multiply(a, b: Vector2) -> Vector2:
	return Vector2(a.x * b.x - a.y * b.y, a.y * b.x - a.x * b.y)

func conj(a):
	return Vector2(a.x, -a.y)

func right_rot(a):
	return Vector2(a.y, -a.x)
	
func left_rot(a):
	return Vector2(-a.y, a.x)
