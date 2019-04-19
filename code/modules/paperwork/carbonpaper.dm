/obj/item/paper/carbon
	icon_state = "paper_stack"
	var/copies_left = 1

/obj/item/paper/carbon/update_icon()
	icon_state = "[copies_left ? "c" : ""]paper[info ? "_words" : ""]"

/obj/item/paper/carbon/verb/removecopy()
	set name = "Remove carbon-copy"
	set category = "Object"
	set src in usr

	if (copies_left > 0)
		var/obj/item/paper/carboncopy/C = copy_paper(usr.loc, /obj/item/paper/carboncopy)
		usr.put_in_hands(C)
		to_chat(usr, "<span class='notice'>You tear off a carbon-copy!</span>")
		copies_left--
		update_icon()
	else
		to_chat(usr, "There are no more carbon copies attached to this paper!")

/obj/item/paper/carbon/can_bundle(mob/user)
	if(copies_left)
		if(user)
			to_chat(user, "<span class='notice'>Take off the carbon cop[copies_left > 1 ? "ies" : "y"] first.</span>")
		return FALSE
	return TRUE

/obj/item/paper/carboncopy
	icon_state = "copypaper"