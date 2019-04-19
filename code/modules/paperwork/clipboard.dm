/obj/item/clipboard
	name = "clipboard"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	var/obj/item/tool/pen/haspen //The stored pen.
	var/obj/item/toppaper //The topmost piece of paper.
	flags_equip_slot = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE

/obj/item/clipboard/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins putting [user.p_their()] head into the clip of \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/clipboard/Initialize()
	. = ..()
	update_icon()
	if(prob(1)) //some videogame reference
		desc = "<span class='italic'>[pick("Hi there, would you like to sign my petition?", "Sign this petition or I'll follow you home and kill your dog.", "Are you gonna sign this or will it be your surviving family members?"]</span>"

/obj/item/clipboard/Destroy()
	QDEL_NULL(haspen)
	QDEL_NULL(toppaper) //let movable/Destroy handle the rest
	return ..()

/obj/item/clipboard/update_icon()
	cut_overlays()
	var/list/dat = list()
	if(toppaper)
		dat += mutable_appearance(toppaper)
	if(haspen)
		dat += "clipboard_pen"
	dat += "clipboard_over"
	add_overlay(dat)

/obj/item/clipboard/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo))
		user.drop_held_item()
		I.forceMove(src)
		if(istype(W, /obj/item/paper))
			toppaper = I
		to_chat(user, "<span class='notice'>You clip \the [W] onto \the [src].</span>")
		update_icon()
	else if(istype(toppaper) && istype(I, /obj/item/tool/pen))
		toppaper.attackby(I, usr)
		update_icon()
	else
		return ..()

/obj/item/clipboard/attack_self(mob/user)
	ui_interact(user)

/obj/item/clipboard/ui_interact(mob/user)
	var/dat = "<title>Clipboard</title>"
	if(haspen)
		dat += "<A href='?src=[REF(src)];pen=1'>Remove Pen</A><BR><HR>"
	else
		dat += "<A href='?src=[REF(src)];addpen=1'>Add Pen</A><BR><HR>"
	//The topmost paper. You can't organise contents directly in byond, so this is what we're stuck with.	-Pete
	if(toppaper)
		var/obj/item/paper/P = toppaper
		dat += "<A href='?src=[REF(src)];write=[REF(P)]'>Write</A> <A href='?src=[REF(src)];remove=[REF(P)]'>Remove</A> - <A href='?src=[REF(src)];read=[REF(P)]'>[P.name]</A><BR><HR>"

		for(P in src)
			if(P == toppaper)
				continue
			dat += "<A href='?src=[REF(src)];write=[REF(P)]'>Write</A> <A href='?src=[REF(src)];remove=[REF(P)]'>Remove</A> <A href='?src=[REF(src)];top=[REF(P)]'>Move to top</A> - <A href='?src=[REF(src)];read=[REF(P)]'>[P.name]</A><BR>"
	add_fingerprint(usr)
	var/datum/browser/popup = new(user, "clipboard", "<div align='center'>[name]</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "clipboard")

/obj/item/clipboard/Topic(href, href_list)
	. = ..()
	if(usr.incapacitated())
		return

	if(!usr.contents.Find(src))
		return
	if(href_list["pen"])
		if(haspen)
			haspen.forceMove(usr.loc)
			usr.put_in_hands(haspen)
			haspen = null

	if(href_list["addpen"])
		if(!haspen)
			var/obj/item/held = usr.get_active_held_item()
			if(istype(held, /obj/item/pen))
				var/obj/item/pen/W = held
				if(!usr.transferItemToLoc(W, src))
					return
				haspen = W
				to_chat(usr, "<span class='notice'>You slot [W] into [src].</span>")

	if(href_list["write"])
		var/obj/item/P = locate(href_list["write"]) in src
		if(istype(P))
			if(usr.get_active_held_item())
				P.attackby(usr.get_active_held_item(), usr)

	if(href_list["remove"])
		var/obj/item/P = locate(href_list["remove"]) in src
		if(istype(P))
			P.forceMove(usr.loc)
			usr.put_in_hands(P)
			if(P == toppaper)
				toppaper = null
				var/obj/item/paper/newtop = locate(/obj/item/paper) in src
				if(newtop && (newtop != P))
					toppaper = newtop
				else
					toppaper = null

	if(href_list["read"])
		var/obj/item/paper/P = locate(href_list["read"]) in src
		if(istype(P))
			usr.examinate(P)

	if(href_list["top"])
		var/obj/item/P = locate(href_list["top"]) in src
		if(istype(P))
			toppaper = P
			to_chat(usr, "<span class='notice'>You move [P.name] to the top.</span>")

		//Update everything
		attack_self(usr)
		update_icon()
