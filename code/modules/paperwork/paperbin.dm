/obj/item/paper_bin
	name = "paper bin"
	desc = "Contains all the paper you'll never need."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	layer = LOWER_ITEM_LAYER
	var/papertype = /obj/item/paper
	var/total_paper = 30
	var/list/papers = list()
	var/obj/item/pen/bin_pen

/obj/item/paper_bin/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	var/obj/item/pen/P = locate(/obj/item/pen) in loc
	if(P && !bin_pen)
		P.forceMove(src)
		bin_pen = P
		update_icon()

/obj/item/paper_bin/Destroy()
	QDEL_LIST(papers)
	papers = null
	. = ..()

/obj/item/paper_bin/fire_act(exposed_temperature, exposed_volume)
	if(total_paper)
		total_paper = 0
		update_icon()
	return ..()

/obj/item/paper_bin/MouseDrop(atom/over_object)
	if(over_object == usr && usr.canUseTopic(src) && (ismonkey(usr) || ishuman(usr)) && !usr.get_active_held_item())
		usr.put_in_hands(src)

/obj/item/paper_bin/attack_paw(mob/user)
	return attack_hand(user)

//ATTACK HAND IGNORING PARENT RETURN VALUE AND I CAN'T HELP
/obj/item/paper_bin/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(bin_pen)
		bin_pen.add_fingerprint(user)
		bin_pen.forceMove(user.loc)
		user.put_in_hands(bin_pen)
		to_chat(user, "<span class='notice'>You take [bin_pen] out of \the [src].</span>")
		bin_pen = null
		update_icon()
	else if(total_paper >= 1)
		total_paper--
		update_icon()
		// If there's any custom paper on the stack, use that instead of creating a new paper.
		var/obj/item/paper/P
		var/toppaper = length(papers)
		if(toppaper)
			P = papers[toppaper]
			papers.Remove(P)
		else
			P = new papertype(src)
			/*
			if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
				if(prob(30))
					P.info = "<font face=\"[CRAYON_FONT]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
					P.rigged = TRUE
					P.updateinfolinks()
			*/
		P.add_fingerprint(user)
		P.forceMove(user.loc)
		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You take [P] out of \the [src].</span>")
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
	add_fingerprint(user)

/obj/item/paper_bin/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/paper))
		var/obj/item/paper/P = I
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		papers.Add(P)
		total_paper++
		update_icon()
	else if(istype(I, /obj/item/pen) && !bin_pen)
		var/obj/item/pen/P = I
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		bin_pen = P
		update_icon()
	else
		return ..()

/obj/item/paper_bin/examine(mob/user)
	. = ..()
	if(total_paper)
		to_chat(user, "It contains " + (total_paper > 1 ? "[total_paper] papers" : " one paper")+".")
	else
		to_chat(user, "It doesn't contain anything.")

/obj/item/paper_bin/update_icon()
	icon_state = "paper_bin[total_paper < 1 ? "0" : ""]"
	cut_overlays()
	if(bin_pen)
		add_overlay(mutable_appearance(bin_pen.icon, bin_pen.icon_state))

/obj/item/paper_bin/carboncopy
	name = "carbon-copy paper bin"
	icon_state = "paper_bin2"
	papertype = /obj/item/paper/carbon

/obj/item/paper_bin/construction
	name = "construction paper bin"
	desc = "Contains all the paper you'll never need, IN COLOR!"
	icon_state = "paper_binc"
	papertype = /obj/item/paper/construction