/*
 * Pens
 */
/obj/item/tool/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	flags_equip_slot = ITEM_SLOT_BELT | ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_speed = 7
	throw_range = 15
	matter = list("metal" = 10)
	var/colour = "black"	//what colour the ink is!
	var/font = PEN_FONT

/obj/item/pen/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is scribbling numbers all over [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return(BRUTELOSS)

/obj/item/tool/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/tool/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/tool/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"

/obj/item/tool/pen/attack(mob/living/M , mob/user, stealth)
	if(istype(M))
		return
	if(force)
		return ..()
	log_combat(user, M, "stabbed", src)
	if(M.can_inject(user, TRUE))
		to_chat(user, "<span class='warning'>You stab [M] with the pen.</span>")
		if(!stealth)
			to_chat(M, "<span class='danger'>You feel a tiny prick!</span>")
		return TRUE

/obj/item/tool/pen/chem
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	container_type = OPENCONTAINER
	origin_tech = "materials=2;syndicate=5"
	var/volume = 50

/obj/item/tool/pen/chem/Initialize(mapload)
	. = ..()
	create_reagents(volume)
	add_initial_reagents()

/obj/item/tool/pen/chem/attack(mob/living/M, mob/user)
	. = ..()
	if(. && istype(M))
		reagents.reaction(M, INJECT, reagents.total_volume)
		reagents.trans_to(M, reagents.total_volume, transfered_by = user)

/obj/item/tool/pen/chem/sleepypen
	volume = 30
	list_reagents = list("chloralhydrate" = 22)

/obj/item/tool/pen/chem/paralysis
	list_reagents = list("zombiepowder" = 10, "cryptobiolin" = 15)
