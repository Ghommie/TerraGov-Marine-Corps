//common figures with reasonably fast drawing methods

/proc/diamond_turfs(atom/center, radius)
	var/turf/center_turf = get_turf(center)
	if(radius < 0 || !center_turf)
		return

	if(radius == 0)
		return list(center_turf)

	var/x_0 = center_turf.x
	var/y_0 = center_turf.y
	var/z_0 = center_turf.z
	var/dx = 0

	. = list(locate(x_0 + radius, y_0, z_0),
			 locate(x_0 - radius, y_0, z_0),
			 locate(x_0, y_0 + radius, z_0),
			 locate(x_0, y_0 - radius, z_0))

	for(var/dy=radius-1 ; dy > 0 ; dy--)
		dx++
		. += locate(x_0 + dx, y_0 + dy, z_0)
		. += locate(x_0 + dx, y_0 - dy, z_0)
		. += locate(x_0 - dx, y_0 + dy, z_0)
		. += locate(x_0 - dx, y_0 - dy, z_0)

/proc/filled_diamond_turfs(atom/center, radius)
	var/turf/center_turf = get_turf(center)
	if(radius < 0 || !center_turf)
		return

	if(radius == 0)
		return list(center_turf)

	var/x_0 = center_turf.x
	var/y_0 = center_turf.y
	var/z_0 = center_turf.z
	var/dx = 0

	. = list(locate(x_0 + radius, y_0, z_0), locate(x_0 - radius, y_0, z_0))
	. += block(locate(x_0, y_0 - radius, z_0), locate(x_0, y_0 + radius, z_0))

	for(var/dy=radius-1 ; dy > 0 ; dy--)
		dx++
		. += block(locate(x_0 + dx, y_0 - dy, z_0), locate(x_0 + dx, y_0 + dy, z_0))
		. += block(locate(x_0 - dx, y_0 - dy, z_0), locate(x_0 - dx, y_0 + dy, z_0))

#define ANDRES_NEXT_STEP \
		if(d >= 2*dx) \
			{ \
			d -= 2*dx + 1; \
			dx++; \
			} \
		else if(d < 2*(radius-dy)) \
			{ \
			d += 2*dy - 1; \
			dy--; \
			} \
		else \
			{ \
			d += 2*(dy-dx-1); \
			dy--; \
			dx++; \
			}

//Andres algorithm for plane filling circles, adapted for non-overlapping turfs
/proc/circle_turfs(atom/center, radius=3)
	var/turf/center_turf = get_turf(center)
	if(radius < 0 || !center_turf)
		return
	if(radius == 0)
		return list(center_turf)

	var/x_0 = center_turf.x
	var/y_0 = center_turf.y
	var/z_0 = center_turf.z

	var/dx = 0
	var/dy = radius
	var/d = radius - 1

	//get rid of the four cardinal that would otherwise overlap
	. = list(locate(x_0 + radius, y_0, z_0), \
			 locate(x_0 - radius, y_0, z_0), \
			 locate(x_0, y_0 + radius, z_0), \
			 locate(x_0, y_0 - radius, z_0))

	ANDRES_NEXT_STEP

	while(dy > dx)
		. += locate(x_0 + dx, y_0 + dy, z_0)
		. += locate(x_0 - dx, y_0 - dy, z_0)
		. += locate(x_0 - dy, y_0 + dx, z_0)
		. += locate(x_0 + dy, y_0 - dx, z_0)
		. += locate(x_0 - dy, y_0 - dx, z_0)
		. += locate(x_0 + dx, y_0 - dy, z_0)
		. += locate(x_0 - dx, y_0 + dy, z_0)
		. += locate(x_0 + dy, y_0 + dx, z_0)

		ANDRES_NEXT_STEP

	//last turfs are on diagonals, don't duplicate them
	if(dx == dy)
		. += locate(x_0 + dx, y_0 + dy, z_0)
		. += locate(x_0 + dx, y_0 - dy, z_0)
		. += locate(x_0 - dx, y_0 + dy, z_0)
		. += locate(x_0 - dx, y_0 - dy, z_0)

#undef ANDRES_NEXT_STEP

//Andres-based again
/proc/filled_circle_turfs(atom/center, radius=3)
	var/turf/center_turf = get_turf(center)
	if(radius < 0 || !center_turf)
		return
	if(radius == 0)
		return list(center_turf)

	var/x_0 = center_turf.x
	var/y_0 = center_turf.y
	var/z_0 = center_turf.z

	var/dx = 0
	var/dy = radius
	var/d = radius - 1

	//draw vertical diameter
	. = block(locate(x_0, y_0 - radius, z_0), locate(x_0, y_0 + radius, z_0))

	do
		//a step left/right, draw a vertical column
		if(d >= 2*dx)
			d -= 2*dx + 1;
			dx++;
			. += block(locate(x_0 + dx, y_0 - dy , z_0), locate(x_0 + dx, y_0 + dy, z_0))
			. += block(locate(x_0 - dx, y_0 - dy, z_0), locate(x_0 - dx, y_0 + dy, z_0))

		else if(d < 2*(radius-dy))
			//a step down/up, so draw by symmetry on the other axis
			d += 2*dy - 1;
			. += block(locate(x_0 + dy, y_0 - dx , z_0), locate(x_0 + dy, y_0 + dx, z_0))
			. += block(locate(x_0 - dy, y_0 - dx, z_0), locate(x_0 - dy, y_0 + dx, z_0))
			dy--;
		else
			//diagonal step, draw on both axis, checking for possible overlap
			d += 2*(dy-dx-1);
			dx++;
			. += block(locate(x_0 + dx, y_0 - dy + 1 , z_0), locate(x_0 + dx, y_0 + dy - 1, z_0))
			. += block(locate(x_0 - dx, y_0 - dy + 1, z_0), locate(x_0 - dx, y_0 + dy - 1, z_0))
			if(dy - 1 <  dx) //we're about to overlap, bail out
				break
			. += block(locate(x_0 + dy, y_0 - dx + 1 , z_0), locate(x_0 + dy, y_0 + dx - 1, z_0))
			. += block(locate(x_0 - dy, y_0 - dx + 1, z_0), locate(x_0 - dy, y_0 + dx - 1, z_0))
			dy--;
	while(dy > dx)

//circlerange with sort-of applied shadow casting.
//excess arguments are used on a conditional callback (e.g. CALLBACK(T, ./CanPass, start, T)).
/proc/circle_casted_turfs(atom/start, radius = 3, inclusive = FALSE, angle_coeff = 1, thingtocall, proctocall, ...)
	var/turf/center = get_turf(start)
	if(!center)
		return
	var/custom_checks = length(args) > 5 ? TRUE : FALSE
	var/perimeter = circle_turfs(center, radius)
	var/diameter = radius * 2 + 1
	var/y_axis = center.y - radius - 1
	var/x_axis = center.x - radius - 1
	var/list/grid
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
			var/unobstacled = FALSE
			if(custom_checks)
				var/object = thingtocall == CALLBACK_DUMMY ? IT : thingtocall
				var/list/arguments = args.Copy(7)
				for(var/A in arguments)
					A = A == CALLBACK_DUMMY ? IT : A
				var/datum/callback/conditions = CALLBACK(object, proctocall, arguments)
				if(conditions.Invoke())
					unobstacled = TRUE
			else if(IT.CanPass(start, IT))
				unobstacled = TRUE
			if(unobstacled)
				grid[IT.x - x_axis][IT.y - y_axis] = T
				continue
			var/bisector = Get_Angle(center, T)
			var/shadow_angle = 90 * (distance/radius) * angle_coeff
			var/sections = round(radius/distance * angle_coeff)
			var/ray = SIMPLIFY_DEGREES(bisector - shadow_angle)
			var/turf/corner = get_turf_in_angle(ray, center, radius)
			var/starter_point = inclusive ? T : null
			for(var/C in getline(IT, corner) - starter_point)
				var/turf/ST = C
				grid[ST.x - x_axis][ST.y - y_axis] = 0
			var/corner_ray = Get_Angle(IT, corner)
			var/section_ray = closer_angle_difference(corner_ray, bisector)/sections * 2
			for(var/i = 1 to sections)
				corner_ray = SIMPLIFY_DEGREES(corner_ray - section_ray)
				for(var/C in getline(IT, corner_ray) - IT)
					var/turf/ST = C
					grid[ST.x - x_axis][ST.y - y_axis] = 0
	var/list/turfs = list()
	for(var/x = 1 to diameter)
		var/list/gridline = x
		for(var/y in gridline)
			var/turf/T = gridline[y]
			if(!T)
				continue
			turfs += T
	return turfs
