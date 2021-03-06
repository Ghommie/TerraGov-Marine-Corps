/mob/proc/can_use_nano(src_object)
	return STATUS_CLOSE // By default no mob can do anything with NanoUI


/mob/proc/shared_nano_interaction()
	if(stat || !client)
		return STATUS_CLOSE						// no updates, close the interface
	else if(incapacitated())
		return STATUS_UPDATE					// update only (orange visibility)
	return STATUS_INTERACTIVE


/mob/living/silicon/ai/shared_nano_interaction()
	if(incapacitated())
		return STATUS_CLOSE
	return ..()


/mob/dead/observer/can_use_nano(src_object)
	if(!client || (isatom(src_object) && get_dist(src_object, src) > client.view))	// Preventing ghosts from having a million windows open by limiting to objects in range
		return STATUS_CLOSE
	if(IsAdminGhost(src))
		return STATUS_INTERACTIVE
	if(istype(src_object, /datum/podlauncher))
		return STATUS_INTERACTIVE
	return STATUS_UPDATE									// Ghosts can view updates


/mob/living/silicon/ai/can_use_nano(src_object)
	. = shared_nano_interaction()
	if(. != STATUS_INTERACTIVE)
		return

	// Prevents the AI from using Topic on admin levels (by for example viewing through the court/thunderdome cameras)
	// unless it's on the same level as the object it's interacting with.
	var/turf/T = get_turf(src_object)
	if(!T || !(z == T.z))
		return STATUS_CLOSE

	// If an object is in view then we can interact with it
	if(src_object in view(client.view, src))
		return STATUS_INTERACTIVE

	else if(src_object in view(client.view, eyeobj))
		return STATUS_INTERACTIVE

	else if(get_dist(src_object, src) <= client.view)	// View does not return what one would expect while installed in an inteliCard
		return STATUS_INTERACTIVE

	return STATUS_CLOSE


//Some atoms such as vehicles might have special rules for how mobs inside them interact with NanoUI.
/atom/proc/contents_nano_distance(src_object, mob/living/user)
	return user.shared_living_nano_distance(src_object)


/mob/living/proc/shared_living_nano_distance(atom/movable/src_object)
	if(istype(src_object, /datum/wires))
		var/datum/wires/W = src_object
		src_object = W.holder
	if(!(src_object in view(4, src))) 	// If the src object is not visable, disable updates
		return STATUS_CLOSE

	var/dist = get_dist(src_object, src)
	if(dist <= 1) // interactive (green visibility)
		// Checking adjacency even when distance is 0 because get_dist() doesn't include Z-level differences and
		// the client might have its eye shifted up/down thus putting src_object in view.
		return Adjacent(src_object) ? STATUS_INTERACTIVE : STATUS_UPDATE
	else if(dist <= 2)
		return STATUS_UPDATE 		// update only (orange visibility)
	else if(dist <= 4)
		return STATUS_DISABLED 		// no updates, completely disabled (red visibility)
	return STATUS_CLOSE


/mob/living/can_use_nano(src_object)
	. = shared_nano_interaction(src_object)
	if(. != STATUS_CLOSE)
		if(loc)
			. = min(., loc.contents_nano_distance(src_object, src))
	if(STATUS_INTERACTIVE)
		return STATUS_UPDATE


/mob/living/carbon/xenomorph/can_use_nano(src_object)
	. = shared_nano_interaction(src_object)
	if(. != STATUS_CLOSE)
		if(loc)
			. = min(., loc.contents_nano_distance(src_object, src))


/mob/living/carbon/human/can_use_nano(src_object)
	. = shared_nano_interaction(src_object)
	if(. != STATUS_CLOSE)
		if(loc)
			. = min(., loc.contents_nano_distance(src_object, src))
		else
			. = min(., shared_living_nano_distance(src_object))
