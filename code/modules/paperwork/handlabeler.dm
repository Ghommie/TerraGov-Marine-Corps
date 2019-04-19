/obj/item/tool/hand_labeler
	name = "hand labeler"
	desc = "A combined label printer and applicator in a portable device, designed to be easy to operate and use."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	var/label
	var/labels_left = 50
	var/on = FALSE

/obj/item/tool/hand_labeler/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is pointing [src] at [user.p_them()]self. [user.p_theyre(TRUE)] going to label [user.p_them()]self as a suicide!</span>")
	labels_left = max(labels_left - 1, 0)
	var/old_real_name = user.real_name
	user.real_name += " (suicide)"
	for(var/atom/A in user.GetAllContents()) // no conflicts with their identification card
		if(istype(A, /obj/item/card/id))
			var/obj/item/card/id/their_card = A
			if(their_card.registered_name != old_real_name) // only renames their card, as opposed to tagging everyone's
				continue
			their_card.registered_name = user.real_name
			their_card.update_label()
	user.mind.name += " (suicide)" // NOT EVEN DEATH WILL TAKE AWAY THE STAIN
	on_off(TRUE)
	label = "suicide"
	return OXYLOSS

/obj/item/tool/hand_labeler/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity || !on)
		return
	if(!labels_left)
		to_chat(user, "<span class='notice'>You've run out of labelling paper, feed some paper into it.</span>")
		return
	if(!length(label))
		to_chat(user, "<span class='warning'>No text set!</span>")
		return
	if(length(A.name) + length(label) > MAX_LABELING_LEN)
		to_chat(user, "<span class='warning'>Label too big!</span>")
		return
	if(isturf(A) || ismob(A))
		to_chat(user, "<span class='notice'>The label won't stick to that.</span>")
		return
	user.visible_message("[user] labels [A] as [label].", \
						 "<span class='notice'>You label [A] as [label].</span>")
	A.name = "[initial(A.name)] ([label])"
	labels_left--

/obj/item/tool/hand_labeler/attack_self(mob/user)
	on_off(!on)
	if(on)
		//Now let them chose the text.
		if(user.is_literate())
			to_chat(user, "<span class='notice'>You turn on [src].</span>")
			var/str = copytext(reject_bad_text(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
			if(loc != user || user.incapacitated())
				return
			if(!str || !length(str))
				to_chat(user, "<span class='warning'>Invalid text!</span>")
				return
			label = str
			to_chat(user, "<span class='notice'>You set the text to '[str]'.</span>")
		else
			to_chat(user, "<span class='warning'>You turn on [src] and type in random text!</span>")
			label = copytext("[pick(verbs + adjectives)] [pick(verbs + adjectives)]", 1, MAX_NAME_LEN)
	else
		to_chat(user, "<span class='notice'>You turn off [src].</span>")

/obj/item/tool/hand_labeler/proc/on_off(mode = FALSE)
	on = mode
	update_icon()

/obj/item/tool/hand_labeler/update_icon()
	icon_state = "labeler[on]"

/obj/item/tool/hand_labeler/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/paper))
		var/obj/item/paper/P = I
		if(!P.can_bundle(user))
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		qdel(I)
		labels_left = min(labels_left + 5, initial(labels_left))

/obj/item/tool/hand_labeler/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It has [labels_left] out of [initial(labels_left)] labels left.")

