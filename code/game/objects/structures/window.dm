/obj/structure/window
	name = "window"
	desc = "A glass window. It looks thin and flimsy. A few knocks with anything should shatter it."
	icon = 'icons/obj/structures/windows.dmi'
	icon_state = "window"
	density = TRUE
	anchored = TRUE
	layer = WINDOW_LAYER
	flags_atom = ON_BORDER
	var/dismantle = FALSE //If we're dismantling the window properly no smashy smashy
	max_integrity = 15
	var/state = 2
	var/reinf = FALSE
	var/basestate = "window"
	var/shardtype = /obj/item/shard
	var/windowknock_cooldown = 0
	var/static_frame = FALSE //If true, can't move the window
	var/junction = 0 //Because everything is terrible, I'm making this a window-level var
	var/damageable = TRUE
	var/deconstructable = TRUE


/obj/structure/window/Initialize(mapload, start_dir, constructed)
	..()

	//player-constructed windows
	if(constructed)
		anchored = FALSE
		state = 0

	if(start_dir)
		setDir(start_dir)

	return INITIALIZE_HINT_LATELOAD


/obj/structure/window/LateInitialize()
	. = ..()
	update_nearby_icons()


/obj/structure/window/Destroy()
	density = FALSE
	update_nearby_icons()
	return ..()


//create_debris creates debris like shards and rods. This also includes the window frame for explosions
//If an user is passed, it will create a "user smashes through the window" message. AM is the item that hits
//Please only fire this after a hit
/obj/structure/window/proc/healthcheck(make_hit_sound = 1, make_shatter_sound = 1, create_debris = 1, mob/user, atom/movable/AM)

	if(!damageable)
		if(make_hit_sound) //We'll still make the noise for immersion's sake
			playsound(loc, 'sound/effects/Glasshit.ogg', 25, 1)
		return
	if(obj_integrity <= 0)
		if(user)
			user.visible_message("<span class='danger'>[user] smashes through [src][AM ? " with [AM]":""]!</span>")
		if(make_shatter_sound)
			playsound(src, "shatter", 50, 1)
		shatter_window(create_debris)
	else
		if(make_hit_sound)
			playsound(loc, 'sound/effects/Glasshit.ogg', 25, 1)

/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)
	//Tasers and the like should not damage windows.
	if(Proj.ammo.damage_type == HALLOSS || Proj.damage <= 0 || Proj.ammo.flags_ammo_behavior == AMMO_ENERGY)
		return FALSE

	if(damageable) //Possible to destroy
		obj_integrity -= Proj.damage
	..()
	healthcheck()
	return TRUE

/obj/structure/window/ex_act(severity)
	if(!damageable) //Impossible to destroy
		return
	switch(severity)
		if(1)
			obj_integrity -= rand(125, 250)
			healthcheck(0, 1, 0)
		if(2)
			obj_integrity -= rand(75, 125)
			healthcheck(0, 1)
		if(3)
			obj_integrity -= rand(25, 75)
			healthcheck(0, 1)

//TODO: Make full windows a separate type of window.
//Once a full window, it will always be a full window, so there's no point
//having the same type for both.
/obj/structure/window/proc/is_full_window()
	if(!(flags_atom & ON_BORDER))
		return TRUE

/obj/structure/window/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGLASS))
		return TRUE
	if(is_full_window())
		return FALSE //Full tile window, you can't move into it!
	if(get_dir(loc, target) == dir)
		return !density
	else
		return TRUE

/obj/structure/window/CheckExit(atom/movable/O, turf/target)
	if(istype(O) && CHECK_BITFIELD(O.flags_pass, PASSGLASS))
		return TRUE
	if(get_dir(O.loc, target) == dir && !is_full_window())
		return FALSE
	return TRUE

/obj/structure/window/hitby(AM as mob|obj)
	..()
	visible_message("<span class='danger'>[src] was hit by [AM].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	if(reinf) tforce *= 0.25
	if(damageable) //Possible to destroy
		obj_integrity = max(0, obj_integrity - tforce)
		if(obj_integrity <= 7 && !reinf && !static_frame)
			anchored = FALSE
			update_nearby_icons()
			step(src, get_dir(AM, src))
	healthcheck()

/obj/structure/window/attack_tk(mob/user as mob)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	playsound(loc, 'sound/effects/glassknock.ogg', 15, 1)

/obj/structure/window/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent == INTENT_HELP)
		playsound(src.loc, 'sound/effects/glassknock.ogg', 25, 1)
		M.visible_message("<span class='warning'>\The [M] creepily taps on [src] with its huge claw.</span>", \
		"<span class='warning'>You creepily tap on [src].</span>", \
		"<span class='warning'>You hear a glass tapping sound.</span>", 5)
	else
		attack_generic(M, M.xeno_caste.melee_damage_lower)

/obj/structure/window/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		if(damageable) //Possible to destroy
			user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
			obj_integrity -= 500
		healthcheck(1, 1, 1, user)

	else if(user.a_intent == INTENT_HARM)

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(H.species.can_shred(H))
				attack_generic(H, 25)
				return

		if(windowknock_cooldown > world.time)
			return
		playsound(loc, 'sound/effects/glassknock.ogg', 25, 1)
		user.visible_message("<span class='warning'>[user] bangs against [src]!</span>",
		"<span class='warning'>You bang against [src]!</span>",
		"<span class='warning'>You hear a banging sound.</span>")
		windowknock_cooldown = world.time + 100
	else
		if(windowknock_cooldown > world.time)
			return
		playsound(loc, 'sound/effects/glassknock.ogg', 15, 1)
		user.visible_message("<span class='notice'>[user] knocks on [src].</span>",
		"<span class='notice'>You knock on [src].</span>",
		"<span class='notice'>You hear a knocking sound.</span>")
		windowknock_cooldown = world.time + 100

/obj/structure/window/attack_paw(mob/user as mob)
	return attack_hand(user)

//Used by attack_animal
/obj/structure/window/proc/attack_generic(mob/living/user, damage = 0)
	if(damageable) //Possible to destroy
		obj_integrity -= damage
	user.animation_attack_on(src)
	user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
	healthcheck(1, 1, 1, user)

/obj/structure/window/attack_animal(mob/user as mob)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)

/obj/structure/window/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/grab) && get_dist(src, user) < 2)
		if(isxeno(user))
			return
		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/M = G.grabbed_thing
		var/state = user.grab_level
		user.drop_held_item()
		switch(state)
			if(GRAB_PASSIVE)
				M.visible_message("<span class='warning'>[user] slams [M] against \the [src]!</span>")
				log_admin("[key_name(usr)] slams [key_name(M)] against \the [src].")
				log_combat(user, M, "slammed", "", "against \the [src]")
				msg_admin_attack("[key_name(usr)] slammed [key_name(M)]'s face' against \the [src].")
				M.apply_damage(7)
				if(damageable) //Possible to destroy
					obj_integrity -= 10
			if(GRAB_AGGRESSIVE)
				M.visible_message("<span class='danger'>[user] bashes [M] against \the [src]!</span>")
				log_admin("[key_name(usr)] bashes [key_name(M)] against \the [src].")
				log_combat(user, M, "bashed", "", "against \the [src]")
				msg_admin_attack("[key_name(usr)] bashed [key_name(M)]'s face' against \the [src].")
				if(prob(50))
					M.KnockDown(1)
				M.apply_damage(10)
				if(damageable) //Possible to destroy
					obj_integrity -= 25
			if(GRAB_NECK)
				M.visible_message("<span class='danger'><big>[user] crushes [M] against \the [src]!</big></span>")
				log_admin("[key_name(usr)] crushes [key_name(M)] against \the [src].")
				log_combat(user, M, "crushed", "", "against \the [src]")
				msg_admin_attack("[key_name(usr)] crushed [key_name(M)]'s face' against \the [src].")
				M.KnockDown(5)
				M.apply_damage(20)
				if(damageable) //Possible to destroy
					obj_integrity -= 50
			
		healthcheck(1, 1, 1, M) //The person thrown into the window literally shattered it

	else if(I.flags_item & NOBLUDGEON)
		return

	else if(isscrewdriver(I) && deconstructable)
		dismantle = TRUE
		if(reinf && state >= 1)
			state = 3 - state
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
			to_chat(user, (state == 1 ? "<span class='notice'>You have unfastened the window from the frame.</span>" : "<span class='notice'>You have fastened the window to the frame.</span>"))
		else if(reinf && state == 0 && !static_frame)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
			to_chat(user, (anchored ? "<span class='notice'>You have fastened the frame to the floor.</span>" : "<span class='notice'>You have unfastened the frame from the floor.</span>"))
		else if(!reinf && !static_frame)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
			to_chat(user, (anchored ? "<span class='notice'>You have fastened the window to the floor.</span>" : "<span class='notice'>You have unfastened the window.</span>"))
		else if(static_frame && state == 0)
			disassemble_window()

	else if(iscrowbar(I) && reinf && state <= 1 && deconstructable)
		dismantle = TRUE
		state = 1 - state
		playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
		to_chat(user, (state ? "<span class='notice'>You have pried the window into the frame.</span>" : "<span class='notice'>You have pried the window out of the frame.</span>"))

	else if(damageable && dismantle == FALSE) //Possible to destroy
		obj_integrity -= I.force
		if(obj_integrity <= 7  && !reinf && !static_frame && deconstructable)
			anchored = FALSE
			update_nearby_icons()
			step(src, get_dir(user, src))
		healthcheck(1, 1, 1, user, I)


/obj/structure/window/proc/disassemble_window()
	var/obj/item/stack/sheet/glass/reinforced/R = new (loc, 2)
	transfer_fingerprints_to(R)
	qdel(src)


/obj/structure/window/proc/shatter_window(create_debris)
	if(create_debris)
		var/atom/A = new shardtype(loc)
		transfer_fingerprints_to(A)
		if(is_full_window())
			new shardtype(loc)
		if(reinf)
			var/obj/item/stack/rods/R = new(loc)
			transfer_fingerprints_to(R)
	qdel(src)


/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(static_frame)
		return FALSE
	if(!deconstructable)
		return FALSE
	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>")
		return FALSE

	setDir(turn(dir, 90))



/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(static_frame)
		return FALSE
	if(!deconstructable)
		return FALSE
	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>")
		return FALSE

	setDir(turn(dir, 270))

/obj/structure/window/Move()
	var/ini_dir = dir
	..()
	setDir(ini_dir)

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	for(var/direction in cardinal)
		for(var/obj/structure/window/W in get_step(src, direction))
			W.update_icon()

//merges adjacent full-tile windows into one (blatant ripoff from game/smoothwall.dm)
/obj/structure/window/update_icon()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	//This spawn is here so windows get properly updated when one gets deleted.
	spawn(2)
		if(!src)
			return
		if(!is_full_window())
			icon_state = "[basestate]"
			return
		if(anchored)
			for(var/obj/structure/window/W in orange(src, 1))
				if(W.anchored && W.density	&& W.is_full_window()) //Only counts anchored, not-destroyed fill-tile windows.
					if(abs(x - W.x) - abs(y - W.y)) //Doesn't count windows, placed diagonally to src
						junction |= get_dir(src, W)
		if(opacity)
			icon_state = "[basestate][junction]"
		else
			if(reinf)
				icon_state = "[basestate][junction]"
			else
				icon_state = "[basestate][junction]"

		return

/obj/structure/window/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		if(damageable)
			obj_integrity -= round(exposed_volume / 100)
		healthcheck(0) //Don't make hit sounds, it's dumb with fire/heat
	..()

/obj/structure/window/phoronbasic
	name = "phoron window"
	desc = "A phoron-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."
	basestate = "phoronwindow"
	icon_state = "phoronwindow"
	shardtype = /obj/item/shard/phoron
	max_integrity = 120

/obj/structure/window/phoronbasic/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 32000)
		obj_integrity -= round(exposed_volume / 1000)
		healthcheck(0) //Don't make hit sounds, it's dumb with fire/heat
	..()

/obj/structure/window/phoronreinforced
	name = "reinforced phoron window"
	desc = "A phoron-glass alloy window with a rod matrice. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic phoron windows are insanely fireproof."
	basestate = "phoronrwindow"
	icon_state = "phoronrwindow"
	shardtype = /obj/item/shard/phoron
	reinf = TRUE
	max_integrity = 160

/obj/structure/window/phoronreinforced/fire_act(exposed_temperature, exposed_volume)
	return

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A glass window with a rod matrice. It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	basestate = "rwindow"
	max_integrity = 40
	reinf = TRUE

/obj/structure/window/reinforced/toughened
	name = "safety glass"
	desc = "A very tough looking glass window with a special rod matrice, probably bullet proof."
	icon_state = "rwindow"
	basestate = "rwindow"
	max_integrity = 300
	reinf = TRUE

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	desc = "A glass window with a rod matrice. It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	basestate = "twindow"
	opacity = TRUE

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	desc = "A glass window with a rod matrice. It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "fwindow"
	basestate = "fwindow"
	max_integrity = 30

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "A shuttle glass window with a rod matrice specialised for heat resistance. It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window"
	basestate = "window"
	max_integrity = 40
	reinf = TRUE
	flags_atom = NONE

/obj/structure/window/shuttle/update_icon() //icon_state has to be set manually
	return

//Framed windows

/obj/structure/window/framed
	name = "theoretical window"
	layer = TABLE_LAYER
	static_frame = TRUE
	flags_atom = NONE //This is not a border object; it takes up the entire tile.
	var/window_frame //For perspective windows,so the window frame doesn't magically dissapear
	var/list/tiles_special = list(/obj/machinery/door/airlock,
		/obj/structure/window/framed,
		/obj/structure/girder,
		/obj/structure/window_frame)
	tiles_with = list(
		/turf/closed/wall)

/obj/structure/window/framed/Initialize()
	relativewall()
	relativewall_neighbours()
	. = ..()

/obj/structure/window/framed/Destroy()
	for(var/obj/effect/alien/weeds/weedwall/window/WW in loc)
		qdel(WW)
	. = ..()

/obj/structure/window/framed/update_nearby_icons()
	relativewall_neighbours()

/obj/structure/window/framed/update_icon()
	relativewall()


/obj/structure/window/framed/disassemble_window()
	if(window_frame)
		var/obj/structure/window_frame/WF = new window_frame(loc)
		transfer_fingerprints_to(WF)
		WF.icon_state = "[WF.basestate][junction]_frame"
		WF.setDir(dir)
	return ..()


/obj/structure/window/framed/shatter_window(create_debris)
	if(window_frame)
		var/obj/structure/window_frame/new_window_frame = new window_frame(loc, TRUE)
		transfer_fingerprints_to(new_window_frame)
		new_window_frame.icon_state = "[new_window_frame.basestate][junction]_frame"
		new_window_frame.setDir(dir)
	return ..()


/obj/structure/window/framed/proc/drop_window_frame()
	if(window_frame)
		var/obj/structure/window_frame/new_window_frame = new window_frame(loc, TRUE)
		transfer_fingerprints_to(new_window_frame)
		new_window_frame.icon_state = "[new_window_frame.basestate][junction]_frame"
		new_window_frame.setDir(dir)
	qdel(src)

/obj/structure/window/framed/almayer
	name = "reinforced window"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "alm_rwindow0"
	basestate = "alm_rwindow"
	max_integrity = 100 //Was 600
	reinf = TRUE
	dir = 5
	window_frame = /obj/structure/window_frame/almayer

/obj/structure/window/framed/almayer/toughened
	name = "safety glass"
	desc = "A very tough looking glass window with a special rod matrice, probably bullet proof."
	max_integrity = 300

/obj/structure/window/framed/almayer/hull
	name = "hull window"
	desc = "A glass window with a special rod matrice inside a wall frame. This one was made out of exotic materials to prevent hull breaches. No way to get through here."
	//icon_state = "rwindow0_debug" //Uncomment to check hull in the map editor
	damageable = FALSE
	deconstructable = FALSE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	max_integrity = 1000000 //Failsafe, shouldn't matter

/obj/structure/window/framed/almayer/requisitions
	name = "kevlar-weave infused bulletproof window"
	desc = "A borosilicate glass window infused with kevlar fibres and mounted within a special shock-absorbing frame, this is gonna be seriously hard to break through."
	max_integrity = 1000
	deconstructable = FALSE

/obj/structure/window/framed/almayer/white
	icon_state = "white_rwindow0"
	basestate = "white_rwindow"
	window_frame = /obj/structure/window_frame/almayer/white



/obj/structure/window/framed/colony
	name = "window"
	icon_state = "col_window0"
	basestate = "col_window"
	window_frame = /obj/structure/window_frame/colony

/obj/structure/window/framed/colony/reinforced
	name = "reinforced window"
	icon_state = "col_rwindow0"
	basestate = "col_rwindow"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	max_integrity = 100
	reinf = 1
	window_frame = /obj/structure/window_frame/colony/reinforced

/obj/structure/window/framed/colony/reinforced/tinted
	name =  "tinted reinforced window"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it. This one is opaque. You have an uneasy feeling someone might be watching from the other side."
	opacity = TRUE

/obj/structure/window/framed/colony/reinforced/hull
	name = "hull window"
	desc = "A glass window with a special rod matrice inside a wall frame. This one was made out of exotic materials to prevent hull breaches. No way to get through here."
	//icon_state = "rwindow0_debug" //Uncomment to check hull in the map editor
	damageable = FALSE
	deconstructable = FALSE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	max_integrity = 1000000 //Failsafe, shouldn't matter



//Chigusa windows

/obj/structure/window/framed/chigusa
	name = "reinforced window"
	icon_state = "chig_rwindow0"
	basestate = "chig_rwindow"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	max_integrity = 100
	reinf = TRUE
	window_frame = /obj/structure/window_frame/chigusa



/obj/structure/window/framed/wood
	name = "window"
	icon_state = "wood_window0"
	basestate = "wood_window"
	window_frame = /obj/structure/window_frame/wood

/obj/structure/window/framed/wood/reinforced
	name = "reinforced window"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	max_integrity = 100
	reinf = TRUE
	icon_state = "wood_rwindow0"
	basestate = "wood_rwindow"
	window_frame = /obj/structure/window_frame/wood

//Prison windows


/obj/structure/window/framed/prison
	name = "window"
	icon_state = "wood_window0"
	basestate = "wood_window"
	window_frame = /obj/structure/window_frame/prison

/obj/structure/window/framed/prison/reinforced
	name = "reinforced window"
	desc = "A glass window with a special rod matrice inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	max_integrity = 100
	reinf = TRUE
	icon_state = "prison_rwindow0"
	basestate = "prison_rwindow"
	window_frame = /obj/structure/window_frame/prison/reinforced

/obj/structure/window/framed/prison/reinforced/hull
	name = "hull window"
	desc = "A glass window with a special rod matrice inside a wall frame. This one has an automatic shutter system to prevent any atmospheric breach."
	max_integrity = 200
	//icon_state = "rwindow0_debug" //Uncomment to check hull in the map editor
	var/triggered = FALSE //indicates if the shutters have already been triggered

/obj/structure/window/framed/prison/reinforced/hull/Destroy()
	spawn_shutters()
	.=..()

/obj/structure/window/framed/prison/reinforced/hull/proc/spawn_shutters(var/from_dir = 0)
	if(triggered)
		return
	else
		triggered = TRUE
	if(!from_dir) //air escaping sound effect for original window
		playsound(src, 'sound/machines/hiss.ogg', 50, 1)
	for(var/direction in cardinal)
		if(direction == from_dir)
			continue //doesn't check backwards
		for(var/obj/structure/window/framed/prison/reinforced/hull/W in get_step(src,direction) )
			W.spawn_shutters(turn(direction,180))
	var/obj/machinery/door/poddoor/shutters/almayer/pressure/P = new(get_turf(src))
	switch(junction)
		if(4,5,8,9,12)
			P.setDir(SOUTH)
		else
			P.setDir(EAST)
	spawn(16)
		P.close()

/obj/structure/window/framed/prison/cell
	name = "cell window"
	icon_state = "prison_cellwindow0"
	basestate = "prison_cellwindow"
	desc = "A glass window with a special rod matrice inside a wall frame. This one was made out of exotic materials to prevent hull breaches. No way to get through here."
	//icon_state = "rwindow0_debug" //Uncomment to check hull in the map editor
	damageable = FALSE
	deconstructable = FALSE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	max_integrity = 1000000 //Failsafe, shouldn't matter
