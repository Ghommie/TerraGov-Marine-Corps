/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/machines/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
	var/obj/item/paper/copy = null	//what's in the copier!
	var/obj/item/photo/photocopy = null
	var/obj/item/paper_bundle/bundle = null
	var/copies = 1	//how many copies to print!
	var/toner = 30 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!

	attack_ai(mob/user as mob)
		return attack_hand(user)

	attack_paw(mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		user.set_interaction(src)

		var/dat
		if(copy || photocopy || bundle)
			dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Paper</a><BR>"
			if(toner)
				dat += "<a href='byond://?src=\ref[src];copy=1'>Copy</a><BR>"
				dat += "Printing: [copies] copies."
				dat += "<a href='byond://?src=\ref[src];min=1'>-</a> "
				dat += "<a href='byond://?src=\ref[src];add=1'>+</a><BR><BR>"
		else if(toner)
			dat += "Please insert paper to copy.<BR><BR>"
		if(istype(user,/mob/living/silicon))
			dat += "<a href='byond://?src=\ref[src];aipic=1'>Print photo from database</a><BR><BR>"
		dat += "Current toner level: [toner]"
		if(!toner)
			dat +="<BR>Please insert a new toner cartridge!"
		user << browse(dat, "window=copier")

		var/datum/browser/popup = new(user, "copier", "<div align='center'>Photocopier</div>")
		popup.set_content(dat)
		popup.open(FALSE)
		onclose(user, "copier")
		return

	Topic(href, href_list)
		if(href_list["copy"])
			if(copy)
				for(var/i = 0, i < copies, i++)
					if(toner > 0 && copy)
						copy(copy)
						sleep(15)
					else
						break
				updateUsrDialog()
			else if(photocopy)
				for(var/i = 0, i < copies, i++)
					if(toner > 0 && photocopy)
						photocopy(photocopy)
						sleep(15)
					else
						break
				updateUsrDialog()
			else if(bundle)
				for(var/i = 0, i < copies, i++)
					if(toner <= 0 || !bundle)
						break
					var/obj/item/paper_bundle/p = new /obj/item/paper_bundle (src)
					var/j = 0
					for(var/obj/item/W in bundle)
						if(toner <= 0)
							to_chat(usr, "<span class='notice'>The photocopier couldn't finish the printjob.</span>")
							break
						else if(istype(W, /obj/item/paper))
							W = copy(W)
						else if(istype(W, /obj/item/photo))
							W = photocopy(W)
						W.loc = p
						p.amount++
						j++
					p.amount--
					p.loc = src.loc
					p.update_icon()
					p.icon_state = "paper_words"
					p.name = bundle.name
					p.pixel_y = rand(-8, 8)
					p.pixel_x = rand(-9, 9)
					sleep(15*j)
				updateUsrDialog()
		else if(href_list["remove"])
			if(copy)
				copy.loc = usr.loc
				usr.put_in_hands(copy)
				to_chat(usr, "<span class='notice'>You take the paper out of \the [src].</span>")
				copy = null
				updateUsrDialog()
			else if(photocopy)
				photocopy.loc = usr.loc
				usr.put_in_hands(photocopy)
				to_chat(usr, "<span class='notice'>You take the photo out of \the [src].</span>")
				photocopy = null
				updateUsrDialog()
			else if(bundle)
				bundle.loc = usr.loc
				usr.put_in_hands(bundle)
				to_chat(usr, "<span class='notice'>You take the paper bundle out of \the [src].</span>")
				bundle = null
				updateUsrDialog()
		else if(href_list["min"])
			if(copies > 1)
				copies--
				updateUsrDialog()
		else if(href_list["add"])
			if(copies < maxcopies)
				copies++
				updateUsrDialog()
		else if(href_list["aipic"])
			if(!istype(usr,/mob/living/silicon)) return
			if(toner >= 5)
				var/mob/living/silicon/tempAI = usr
				var/obj/item/camera/siliconcam/camera = tempAI.aiCamera

				if(!camera)
					return
				var/datum/picture/selection = camera.selectpicture()
				if (!selection)
					return

				var/obj/item/photo/p = new /obj/item/photo (src.loc)
				p.construct(selection)
				if (p.desc == "")
					p.desc += "Copied by [tempAI.name]"
				else
					p.desc += " - Copied by [tempAI.name]"
				toner -= 5
				sleep(15)
			updateUsrDialog()

	attackby(obj/item/O as obj, mob/user as mob)
		if(istype(O, /obj/item/paper))
			if(!copy && !photocopy && !bundle)
				if(user.transferItemToLoc(O, src))
					copy = O
					to_chat(user, "<span class='notice'>You insert the paper into \the [src].</span>")
					flick("bigscanner1", src)
					updateUsrDialog()
			else
				to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
		else if(istype(O, /obj/item/photo))
			if(!copy && !photocopy && !bundle)
				if(user.transferItemToLoc(O, src))
					photocopy = O
					to_chat(user, "<span class='notice'>You insert the photo into \the [src].</span>")
					flick("bigscanner1", src)
					updateUsrDialog()
			else
				to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
		else if(istype(O, /obj/item/paper_bundle))
			if(!copy && !photocopy && !bundle)
				if(user.transferItemToLoc(O, src))
					bundle = O
					to_chat(user, "<span class='notice'>You insert the bundle into \the [src].</span>")
					flick("bigscanner1", src)
					updateUsrDialog()
		else if(istype(O, /obj/item/toner))
			if(toner == 0)
				if(user.temporarilyRemoveItemFromInventory(O))
					qdel(O)
					toner = 30
					to_chat(user, "<span class='notice'>You insert the toner cartridge into \the [src].</span>")
					updateUsrDialog()
			else
				to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
		else if(iswrench(O))
			playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return

	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
			if(2.0)
				if(prob(50))
					qdel(src)
				else
					if(toner > 0)
						new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
						toner = 0
			else
				if(prob(50))
					if(toner > 0)
						new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
						toner = 0
		return

/obj/machinery/photocopier/proc/copy(obj/item/paper/original)
	var/obj/item/paper/copy = new /obj/item/paper (loc)
	if(toner > 10)	//lots of toner, make it dark
		copy.info = "<font color = #101010>"
	else			//no toner? shitty copies for you!
		copy.info = "<font color = #808080>"
	var/copied = original.info
	copied = oldreplacetext(copied, "<font face=\"[copy.deffont]\" color=", "<font face=\"[copy.deffont]\" nocolor=")	//state of the art techniques in action
	copied = oldreplacetext(copied, "<font face=\"[copy.crayonfont]\" color=", "<font face=\"[copy.crayonfont]\" nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
	copy.info += copied
	copy.info += "</font>"
	copy.name = original.name // -- Doohl
	copy.fields = original.fields
	copy.stamps = original.stamps
	copy.stamped = original.stamped
	copy.ico = original.ico
	copy.offset_x = original.offset_x
	copy.offset_y = original.offset_y

	//Iterates through stamps and puts a matching gray overlay onto the copy
	var/image/img                                //
	for (var/j = 1, j <= original.ico.len, j++)
		if (findtext(original.ico[j], "cap") || findtext(original.ico[j], "cent"))
			img = image('icons/obj/bureaucracy.dmi', "paper_stamp-circle")
		else if (findtext(original.ico[j], "deny"))
			img = image('icons/obj/bureaucracy.dmi', "paper_stamp-x")
		else
			img = image('icons/obj/bureaucracy.dmi', "paper_stamp-dots")
		img.pixel_x = original.offset_x[j]
		img.pixel_y = original.offset_y[j]
		copy.overlays += img
	copy.updateinfolinks()
	toner--
	copy.update_icon()
	return copy


/obj/machinery/photocopier/on_stored_atom_del(atom/movable/AM)
	if(AM == copy)
		copy = null
	else if(AM == photocopy)
		photocopy = null
	else if(AM == bundle)
		bundle = null

/obj/machinery/photocopier/proc/photocopy(obj/item/photo/photocopy)
	var/obj/item/photo/p = new /obj/item/photo (src.loc)
	var/icon/I = icon(photocopy.icon, photocopy.icon_state)
	var/icon/img = icon(photocopy.img)
	var/icon/tiny = icon(photocopy.tiny)
	if(toner > 10)	//plenty of toner, go straight greyscale
		I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))		//I'm not sure how expensive this is, but given the many limitations of photocopying, it shouldn't be an issue.
		img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
		tiny.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
	else			//not much toner left, lighten the photo
		I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
		img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
		tiny.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
	p.icon = I
	p.img = img
	p.tiny = tiny
	p.name = photocopy.name
	p.desc = photocopy.desc
	p.scribble = photocopy.scribble
	toner -= 5	//photos use a lot of ink!
	if(toner < 0)
		toner = 0
	return p


/obj/item/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"

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
	var/obj/item/paper/copy //what's in the copier!
	var/obj/item/photo/photocopy = null
	var/obj/item/documents/doccopy = null
	var/copies = 1 //how many copies to print!
	var/toner = 40 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once
	var/greytoggle = "Greyscale"
	var/mob/living/ass
	var/busy = FALSE

/obj/machinery/photocopier/ui_interact(mob/user)
	. = ..()
	var/dat = "Photocopier<BR><BR>"
	if(copy || photocopy || doccopy || (ass && (ass.loc == src.loc)))
		dat += "<a href='byond://?src=[REF(src)];remove=1'>Remove Paper</a><BR>"
		if(toner)
			dat += "<a href='byond://?src=[REF(src)];copy=1'>Copy</a><BR>"
			dat += "Printing: [copies] copies."
			dat += "<a href='byond://?src=[REF(src)];min=1'>-</a> "
			dat += "<a href='byond://?src=[REF(src)];add=1'>+</a><BR><BR>"
			if(photocopy)
				dat += "Printing in <a href='byond://?src=[REF(src)];colortoggle=1'>[greytoggle]</a><BR><BR>"
	else if(toner)
		dat += "Please insert paper to copy.<BR><BR>"
	if(isAI(user))
		dat += "<a href='byond://?src=[REF(src)];aipic=1'>Print photo from database</a><BR><BR>"
	dat += "Current toner level: [toner]"
	if(!toner)
		dat +="<BR>Please insert a new toner cartridge!"
	user << browse(dat, "window=copier")
	onclose(user, "copier")

/obj/machinery/photocopier/Topic(href, href_list)
	if(..())
		return
	if(href_list["copy"])
		if(copy)
			for(var/i = 0, i < copies, i++)
				if(toner > 0 && !busy && copy)
					var/copy_as_paper = 1
					if(istype(copy, /obj/item/paper/contract/employment))
						var/obj/item/paper/contract/employment/E = copy
						var/obj/item/paper/contract/employment/C = new /obj/item/paper/contract/employment (loc, E.target.current)
						if(C)
							copy_as_paper = 0
					if(copy_as_paper)
						var/obj/item/paper/c = new /obj/item/paper (loc)
						if(length(copy.info) > 0)	//Only print and add content if the copied doc has words on it
							if(toner > 10)	//lots of toner, make it dark
								c.info = "<font color = #101010>"
							else			//no toner? shitty copies for you!
								c.info = "<font color = #808080>"
							var/copied = copy.info
							copied = replacetext(copied, "<font face=\"[PEN_FONT]\" color=", "<font face=\"[PEN_FONT]\" nocolor=")	//state of the art techniques in action
							copied = replacetext(copied, "<font face=\"[CRAYON_FONT]\" color=", "<font face=\"[CRAYON_FONT]\" nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
							c.info += copied
							c.info += "</font>"
							c.name = copy.name
							c.fields = copy.fields
							c.update_icon()
							c.updateinfolinks()
							c.stamps = copy.stamps
							if(copy.stamped)
								c.stamped = copy.stamped.Copy()
							c.copy_overlays(copy, TRUE)
							toner--
					busy = TRUE
					sleep(15)
					busy = FALSE
				else
					break
			updateUsrDialog()
		else if(photocopy)
			for(var/i = 0, i < copies, i++)
				if(toner >= 5 && !busy && photocopy)  //Was set to = 0, but if there was say 3 toner left and this ran, you would get -2 which would be weird for ink
					new /obj/item/photo (loc, photocopy.picture.Copy(greytoggle == "Greyscale"? TRUE : FALSE))
					busy = TRUE
					sleep(15)
					busy = FALSE
				else
					break
		else if(doccopy)
			for(var/i = 0, i < copies, i++)
				if(toner > 5 && !busy && doccopy)
					new /obj/item/documents/photocopy(loc, doccopy)
					toner-= 6 // the sprite shows 6 papers, yes I checked
					busy = TRUE
					sleep(15)
					busy = FALSE
				else
					break
			updateUsrDialog()
		else if(ass) //ASS COPY. By Miauw
			for(var/i = 0, i < copies, i++)
				var/icon/temp_img
				if(ishuman(ass) && (ass.get_item_by_slot(SLOT_W_UNIFORM) || ass.get_item_by_slot(SLOT_WEAR_SUIT)))
					to_chat(usr, "<span class='notice'>You feel kind of silly, copying [ass == usr ? "your" : ass][ass == usr ? "" : "\'s"] ass with [ass == usr ? "your" : "[ass.p_their()]"] clothes on.</span>" )
					break
				else if(toner >= 5 && !busy && check_ass()) //You have to be sitting on the copier and either be a xeno or a human without clothes on.
					if(isalienadult(ass) || istype(ass, /mob/living/simple_animal/hostile/alien)) //Xenos have their own asses, thanks to Pybro.
						temp_img = icon('icons/ass/assalien.png')
					else if(ishuman(ass)) //Suit checks are in check_ass
						temp_img = icon(ass.gender == FEMALE ? 'icons/ass/assfemale.png' : 'icons/ass/assmale.png')
					else if(isdrone(ass)) //Drones are hot
						temp_img = icon('icons/ass/assdrone.png')
					else
						break
					busy = TRUE
					sleep(15)
					var/obj/item/photo/p = new /obj/item/photo (loc)
					var/datum/picture/toEmbed = new(name = "[ass]'s Ass", desc = "You see [ass]'s ass on the photo.", image = temp_img)
					p.pixel_x = rand(-10, 10)
					p.pixel_y = rand(-10, 10)
					toEmbed.psize_x = 128
					toEmbed.psize_y = 128
					p.set_picture(toEmbed, TRUE, TRUE)
					toner -= 5
					busy = FALSE
				else
					break
		updateUsrDialog()
	else if(href_list["remove"])
		if(copy)
			remove_photocopy(copy, usr)
			copy = null
		else if(photocopy)
			remove_photocopy(photocopy, usr)
			photocopy = null
		else if(doccopy)
			remove_photocopy(doccopy, usr)
			doccopy = null
		else if(check_ass())
			to_chat(ass, "<span class='notice'>You feel a slight pressure on your ass.</span>")
		updateUsrDialog()
	else if(href_list["min"])
		if(copies > 1)
			copies--
			updateUsrDialog()
	else if(href_list["add"])
		if(copies < maxcopies)
			copies++
			updateUsrDialog()
	else if(href_list["aipic"])
		if(!isAI(usr))
			return
		if(toner >= 5 && !busy)
			var/mob/living/silicon/ai/tempAI = usr
			if(tempAI.aicamera.stored.len == 0)
				to_chat(usr, "<span class='boldannounce'>No images saved</span>")
				return
			var/datum/picture/selection = tempAI.aicamera.selectpicture(usr)
			var/obj/item/photo/photo = new(loc, selection)
			photo.pixel_x = rand(-10, 10)
			photo.pixel_y = rand(-10, 10)
			toner -= 5	 //AI prints color pictures only, thus they can do it more efficiently
			busy = TRUE
			sleep(15)
			busy = FALSE
		updateUsrDialog()
	else if(href_list["colortoggle"])
		if(greytoggle == "Greyscale")
			greytoggle = "Color"
		else
			greytoggle = "Greyscale"
		updateUsrDialog()

/obj/machinery/photocopier/proc/do_insertion(obj/item/O, mob/user)
	O.forceMove(src)
	to_chat(user, "<span class ='notice'>You insert [O] into [src].</span>")
	flick("photocopier1", src)
	updateUsrDialog()

/obj/machinery/photocopier/proc/remove_photocopy(obj/item/O, mob/user)
	if(!issilicon(user)) //surprised this check didn't exist before, putting stuff in AI's hand is bad
		O.forceMove(user.loc)
		user.put_in_hands(O)
	else
		O.forceMove(drop_location())
	to_chat(user, "<span class='notice'>You take [O] out of [src].</span>")

/obj/machinery/photocopier/attackby(obj/item/O, mob/user, params)
	if(default_unfasten_wrench(user, O))
		return

	else if(istype(O, /obj/item/paper))
		if(copier_empty())
			if(istype(O, /obj/item/paper/contract/infernal))
				to_chat(user, "<span class='warning'>[src] smokes, smelling of brimstone!</span>")
				resistance_flags |= FLAMMABLE
				fire_act()
			else
				if(!user.temporarilyRemoveItemFromInventory(O))
					return
				copy = O
				do_insertion(O, user)
		else
			to_chat(user, "<span class='warning'>There is already something in [src]!</span>")

	else if(istype(O, /obj/item/photo))
		if(copier_empty())
			if(!user.temporarilyRemoveItemFromInventory(O))
				return
			photocopy = O
			do_insertion(O, user)
		else
			to_chat(user, "<span class='warning'>There is already something in [src]!</span>")

	else if(istype(O, /obj/item/documents))
		if(copier_empty())
			if(!user.temporarilyRemoveItemFromInventory(O))
				return
			doccopy = O
			do_insertion(O, user)
		else
			to_chat(user, "<span class='warning'>There is already something in [src]!</span>")

	else if(istype(O, /obj/item/toner))
		if(toner <= 0)
			if(!user.temporarilyRemoveItemFromInventory(O))
				return
			qdel(O)
			toner = 40
			to_chat(user, "<span class='notice'>You insert [O] into [src].</span>")
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")

	else if(istype(O, /obj/item/areaeditor/blueprints))
		to_chat(user, "<span class='warning'>The Blueprint is too large to put into the copier. You need to find something else to record the document</span>")
	else
		return ..()

/obj/machinery/photocopier/obj_break(damage_flag)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(toner > 0)
			new /obj/effect/decal/cleanable/oil(get_turf(src))
			toner = 0

/obj/machinery/photocopier/MouseDrop_T(mob/target, mob/user)
	check_ass() //Just to make sure that you can re-drag somebody onto it after they moved off.
	if (!istype(target) || target.anchored || target.buckled || !Adjacent(target) || !user.canUseTopic(src, BE_CLOSE) || target == ass || copier_blocked())
		return
	src.add_fingerprint(user)
	if(target == user)
		user.visible_message("[user] starts climbing onto the photocopier!", "<span class='notice'>You start climbing onto the photocopier...</span>")
	else
		user.visible_message("<span class='warning'>[user] starts putting [target] onto the photocopier!</span>", "<span class='notice'>You start putting [target] onto the photocopier...</span>")

	if(do_after(user, 20, target = src))
		if(!target || QDELETED(target) || QDELETED(src) || !Adjacent(target)) //check if the photocopier/target still exists.
			return

		if(target == user)
			user.visible_message("[user] climbs onto the photocopier!", "<span class='notice'>You climb onto the photocopier.</span>")
		else
			user.visible_message("<span class='warning'>[user] puts [target] onto the photocopier!</span>", "<span class='notice'>You put [target] onto the photocopier.</span>")

		target.forceMove(drop_location())
		ass = target

		if(photocopy)
			photocopy.forceMove(drop_location())
			visible_message("<span class='warning'>[photocopy] is shoved out of the way by [ass]!</span>")
			photocopy = null

		else if(copy)
			copy.forceMove(drop_location())
			visible_message("<span class='warning'>[copy] is shoved out of the way by [ass]!</span>")
			copy = null
	updateUsrDialog()

/obj/machinery/photocopier/proc/check_ass() //I'm not sure wether I made this proc because it's good form or because of the name.
	if(!ass)
		return FALSE
	if(ass.loc != loc)
		ass = null
		updateUsrDialog()
		return FALSE
	else if(ishuman(ass))
		if(!ass.get_item_by_slot(SLOT_W_UNIFORM) && !ass.get_item_by_slot(SLOT_WEAR_SUIT))
			return TRUE
		else
			return FALSE
	else
		return TRUE

/obj/machinery/photocopier/proc/copier_blocked()
	if(QDELETED(src))
		return
	if(loc.density)
		return TRUE
	for(var/atom/movable/AM in loc)
		if(AM == src)
			continue
		if(AM.density)
			return TRUE
	return FALSE

/obj/machinery/photocopier/proc/copier_empty()
	if(copy || photocopy || check_ass())
		return FALSE
	return TRUE

/*
 * Toner cartridge
 */
/obj/item/toner
	name = "toner cartridge"
	icon = 'icons/obj/device.dmi'
	icon_state = "tonercartridge"
	grind_results = list("iodine" = 40, "iron" = 10)
	var/charges = 5
	var/max_charges = 5

