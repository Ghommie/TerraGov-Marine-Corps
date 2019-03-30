//circlerange & co with applied shadow casting, like a FOV.
//excess arguments are used on a conditional callback (e.g. CALLBACK(T, ./CanPass, start, T)).
/proc/shadowcasted_turfs(atom/start, radius = 3, inclusive = FALSE, angle_coeff = 1, curve_coeff = 0, thingtocall, proctocall, ...)
	var/center = get_turf(start)
	if(!center)
		return
	var/custom_checks = length(args) < 7 ? FALSE : TRUE
	var/turfs = circle_turfs(center, radius)
	var/diameter = radius * 2 + 1
	var/y_axis = center.y - radius - 1
	var/x_axis = center.x - radius - 1
	var/list/grid[diameter][diameter]
	grid[center.x - x_axis][center.y - y_axis] = center
	for(var/I in turfs)
		var/turf/T = I
		var/distance
		var/castline = getline(center, T) - center
		for(var/O in castline)
			distance++
			var/turf/IT = O
			if(grid[IT.x - x_axis][IT.y - y_axis] == FALSE)
				break
			var/unobstacled
			if(custom_checks)
				var/object = thingtocall == CALLBACK_DUMMY ? IT : thingtocall
				var/list/arguments = args.Copy(8)
				for(var/A in arguments)
					A = A == CALLBACK_DUMMY ? IT : A
				var/datum/callback/conditions = CALLBACK(object, proctocall, arglist(arguments))
				if(conditions.Invoke())
					unobstacled = TRUE
			else if(IT.canPass(start, IT))
					unobstacled = TRUE
			if(unobstacled)
				var/x = IT.x - x_axis
				var/y = IT.y - y_axis
				grid[x][y] = T
				continue
			var/line_angle = Get_Angle(center, T)
			var/p_angle1 = angle - 90
			ver/p_angle2 = angle + 90
			var/midangle = 45 * (distance/radius) * angle_coeff
			var/ray = line_angle + midangle
			var/incidence_dist = CEILING(distance + (radius - distance) * 0.5)
			var/turf/bisected = castline[incidence_dist]
			var/turf/triangle1 = get_turf_in_angle(p_angle1, bisected, incidence_dist)
			var/turf/triangle2 = get_turf_in_angle(p_angle2, bisected, incidence_dist)
			var/hypotenuse = cheap_hypotenuse(IT.x, IT.y, triangle.x, triangle.y)
			var/list/circle1 = circle_turfs(triangle1, hypotenuse)
			var/list/circle2 = circle_turfs(triangle2, hypotenuse)
			for(var/L in circle1)
				var/turf/segment = L
				if(!(Get_Angle(triangle1, segment) in (p_angle2 - midangle) to (p_angle2 + midangle))
					circle1 -= segment
					continue
				grid[segment.x - x_axis][segment.y - y_axis] = 0
			for(var/L in circle2)
				var/turf/segment = L
				if(!(Get_Angle(triangle2, segment) in (p_angle1 - midangle) to (p_angle1 + midangle))
					circle2 -= segment
					continue
				grid[segment.x - x_axis][segment.y - y_axis] = 0



//midpoint circle algorithm
//then use the perpendicular to mirror the line.



