//circlerange & co with applied shadow casting, like a FOV.
//excess arguments are used on a conditional callback (e.g. CALLBACK(T, ./CanPass, start, T)).
/proc/circle_casted_turfs(atom/start, radius = 3, inclusive = FALSE, angle_coeff = 1, thingtocall, proctocall, ...)
	var/center = get_turf(start)
	if(!center)
		return
	var/custom_checks = length(args) < 5 ? FALSE : TRUE
	var/perimeter = circle_turfs(center, radius)
	var/diameter = radius * 2 + 1
	var/y_axis = center.y - radius - 1
	var/x_axis = center.x - radius - 1
	var/list/grid[diameter][diameter]
	grid[center.x - x_axis][center.y - y_axis] = center
	for(var/I in perimeter)
		var/turf/T = I
		var/distance
		var/castline = getline(center, T) - center
		for(var/O in castline)
			distance++
			var/turf/IT = O
			if(grid[IT.x - x_axis][IT.y - y_axis] == 0)
				break
			var/unobstacled
			if(custom_checks)
				var/object = thingtocall == CALLBACK_DUMMY ? IT : thingtocall
				var/list/arguments = args.Copy(7)
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
			var/bisect_ray = Get_Angle(center, T)
			var/shadow = 90 * (distance/radius) * angle_coeff
			var/sections = round(radius/distance * angle_coeff)
			var/ray = SIMPLIFY_DEGREES(line_angle - midangle)
			var/turf/corner = get_turf_in_angle(ray, center, radius)
			for(var/C in getline(IT, corner) - IT)
				var/turf/ST = C
				grid[ST.x - x_axis][ST.y - y_axis] = 0
			var/corner_ray = Get_Angle(IT, corner)
			var/section_ray = closer_angle_difference(corner_ray, bisect_ray)/sections * 2
			for(var/i = 1 to sections)
				corner_ray = SIMPLIFY_DEGREES(corner_ray - section_ray)
				for(var/C in getline(IT, corner_ray) - IT)
					var/turf/ST = C
					grid[ST.x - x_axis][ST.y - y_axis] = 0
	var/list/turfs = list()
	for(var/r = 1 to diameter)
		turfs += grid[r]
	return turfs
