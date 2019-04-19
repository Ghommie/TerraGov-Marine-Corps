/*	Photocopiers!
 *	Contains:
 *		Photocopier
 *		Toner Cartridge
 */

/*
 * Photocopier
 */
/obj/machinery/photocopier
	name = "photocopier"
	desc = "Used to copy important documents and anatomy studies."
	icon = 'icons/obj/library.dmi'
	icon_state = "photocopier"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
//	max_integrity = 300
//	integrity_failure = 100
	var/obj/item/copy //what's in the copier!
	var/copies = 1 //how many copies to print!
	var/toner = 30 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once
	var/greytoggle = TRUE
	var/mob/living/ass
	var/busy = FALSE
	var/list/canhold = list(/obj/item/paper, /obj/item/photo, /obj/item/paper_bundle, /obj/item/documents, /obj/item/toner)

/obj/machinery/photocopier/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/attack_paw(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/on_stored_atom_del(atom/movable/AM)
	if(AM == copy)
		copy = null
	return ..()

/obj/machinery/photocopier/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
			else if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
		else if(prob(50) && toner > 0)
			new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
			toner = 0

/obj/machinery/photocopier/ui_interact(mob/user)
	. = ..()
	var/dat = "Photocopier<BR><BR>"
	if(busy)
		dat += "Currently busy, please stand by.<BR>"
	else if(copy)
		dat += "<a href='byond://?src=[REF(src)];remove=1'>Remove Paper</a><BR>"
		if(toner)
			dat += "<a href='byond://?src=[REF(src)];copy=1'>Copy</a><BR>"
			dat += "Printing: [copies] copies."
			dat += "<a href='byond://?src=[REF(src)];min=1'>-</a> "
			dat += "<a href='byond://?src=[REF(src)];add=1'>+</a><BR><BR>"
			if(photocopy)
				dat += "Printing in <a href='byond://?src=[REF(src)];colortoggle=1'>[greytoggle ? "Grayscale" : "Colored"]</a><BR><BR>"
			if(isAI(user))
				dat += "<a href='byond://?src=[REF(src)];aipic=1'>Print photo from database</a><BR><BR>"
	else if(toner)
		dat += "Please insert paper to copy.<BR><BR>"
	dat += "Current toner level: [toner]"
	switch(toner)
		if(-INFINITY to 0)
			dat +="<BR>Please insert a new toner cartridge!"
		if(0 to 9)
			dat += "<BR>toner cartridge level low!"
	var/datum/browser/popup = new(user, "copier", "<div align='center'>Photocopier</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "copier")

/obj/machinery/photocopier/Topic(href, href_list)
	. = ..()
	if(. || busy)
		return
	if(href_list["copy"])
		photocopy(copy, copies, TRUE)
	else if(href_list["remove"])
		remove_photocopy(copy, usr)
	else if(href_list["min"])
		if(copies > 1)
			copies--
	else if(href_list["add"])
		if(copies < maxcopies)
			copies++
	else if(href_list["aipic"])
		if(!isAI(usr) || toner < 5)
			return
		var/mob/living/silicon/ai/AI = usr
		var/obj/item/camera/siliconcam/camera = AI.aiCamera
		var/datum/picture/selection = camera?.selectpicture()
		if (!selection)
			return
		var/obj/item/photo/P = new(loc)
		P.construct(selection)
		P.desc += "[P.desc == "" ? "" : " - "]Copied by [AI.name]"
		toner -= 5
		set_busy(TRUE, 15)
	else if(href_list["colortoggle"])
		greytoggle = !greytoggle
	updateUsrDialog()

/obj/machinery/photocopier/proc/photocopy(obj/item/target, counter = 1, first_run = FALSE)
	if(QDELETED(target) || target != copy)
		return FALSE
	if(first_run)
		set_busy(TRUE)
	else if(!target.photocopy_act(src))
		set_busy(FALSE)
		visible_message("<span class='notice'>A red light on \the [src] flashes as it couldn't complete the task.</span>")
		updateUsrDialog()
		return FALSE
	if(counter--)
		addtimer(CALLBACK(target, .proc/photocopy, copy, counter), 15)
	updateUsrDialog()
	return TRUE

/obj/machinery/photocopier/proc/set_busy(business = TRUE, timer)
	busy = business
	update_icon()
	if(timer)
		addtimer(CALLBACK, .proc/set_busy, !business) timer)

/obj/machinery/photocopier/proc/remove_photocopy(obj/item/O, mob/user)
	if(!issilicon(user)) //surprised this check didn't exist before, putting stuff in AI's hand is bad
		O.forceMove(user.loc)
		user.put_in_hands(O)
	else
		O.forceMove(drop_location())
	to_chat(user, "<span class='notice'>You take [O] out of [src].</span>")

/obj/machinery/photocopier/attackby(obj/item/O, mob/user)
	if(is_type_in_list(O, canhold) && O.photocopier_insertion(src, user))
		updateUsrDialog()
	else if(iswrench(O))
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
	else
		return ..()

/obj/machinery/photocopier/proc/copier_empty(mob/user)
	if(copy)
		if(user)
			to_chat(user, "<span class='warning'>There is already something in [src]!</span>")
		return FALSE
	return TRUE

/*
 * Toner cartridge
 */
/obj/item/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"
	grind_results = list("iodine" = 40, "iron" = 10)
	var/charges = 5
	var/max_charges = 5

/obj/item/toner/photocopier_insertion(obj/machinery/photocopier/P)
	if(P.toner > 0)
		to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
		return FALSE
	P.toner = 30
	to_chat(user, "<span class='notice'>You insert \the [src] into \the [P].</span>")
	qdel(src)
	return TRUE
