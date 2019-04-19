/*
 * Paper
 * also scraps of paper
 *
 * lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!
 */

/obj/item/paper
	name = "paper"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	slot_flags = ITEM_SLOT_HEAD
	flags_armor_protection = HEAD
	resistance_flags = FLAMMABLE
	//max_integrity = 50
	attack_verb = list("bapped")

	var/info		//What's actually written on the paper.
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/image_threshold = 20 //Maximum capacity for logos and stamps.
	var/list/logos
	var/stamps		//The (text for the) stamps on the paper.
	var/fields = 0	//Amount of user created fields
	var/list/stamped
//	var/rigged = FALSE
	var/spam_flag = FALSE
	var/contact_poison // Reagent ID to transfer on contact
	var/contact_poison_volume = 0

/obj/item/paper/pickup(user)
	if(contact_poison && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || G.transfer_prints)
			H.reagents.add_reagent(contact_poison,contact_poison_volume)
			contact_poison = null
	..()


/obj/item/paper/Initialize()
	. = ..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	update_icon()
	updateinfolinks()


/obj/item/paper/update_icon()

	if(resistance_flags & ON_FIRE)
		icon_state = "paper_onfire"
		return
	if(info)
		icon_state = "paper_words"
		return
	icon_state = "paper"


/obj/item/paper/examine(mob/user)
	. = ..()
	readme(user)

/obj/item/paper/proc/readme(user)
	if(is_blind(user))
		return
	var/datum/asset/assets = get_asset_datum(/datum/asset/spritesheet/simple/paper)
	assets.send(user)
	if(in_range(user, src) || isobserver(user))
		if(user.is_literate())
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info]<HR>[stamps]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
		else
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)]<HR>[stamps]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
	else
		to_chat(user, "<span class='warning'>You're too far away to read it!</span>")


/obj/item/paper/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] scratches a grid on [user.p_their()] wrist with the paper! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return (BRUTELOSS)


/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if(usr.incapacitated() || !usr.is_literate())
		return
	if((CLUMSY in usr.mutations) && prob(25))
		to_chat(usr, "<span class='warning'>You cut yourself on the paper! Ahhhh! Ahhhhh!</span>")
		damageoverlaytemp = 9001
		flash_pain()
		return
	var/n_name = stripped_input(usr, "What would you like to label the paper?", "Paper Labelling", null, MAX_NAME_LEN)
	if((loc == usr && usr.stat == CONSCIOUS))
		name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)


/obj/item/paper/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] scratches a grid on [user.p_their()] wrist with the paper! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return (BRUTELOSS)

/*
/obj/item/paper/proc/reset_spamflag()
	spam_flag = FALSE

/obj/item/paper/attack_self(mob/user)
	user.examinate(src)
	if(rigged && (SSevents.holidays && SSevents.holidays[APRIL_FOOLS]))
		if(!spam_flag)
			spam_flag = TRUE
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			addtimer(CALLBACK(src, .proc/reset_spamflag), 20) */

/obj/item/paper/attack_ai(mob/living/silicon/ai/user)
	var/dist
	if(istype(user) && user.camera) //is AI
		dist = get_dist(src, user.camera)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2)
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info]<HR>[stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	else
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)]<HR>[stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")

/obj/item/paper/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(user.zone_selected == "eyes")
		user.visible_message("<span class='notice'>You show the paper to [M]. </span>", \
			"<span class='notice'> [user] holds up a paper and shows it to [M]. </span>")
		readme(M)
		return
	if(user.zone_selected != "mouth" || !ishuman(M)) // lipstick wiping
		return ..()
	var/mob/living/carbon/human/H = M
	if(H == user)
		to_chat(user, "<span class='notice'>You wipe off the lipstick with [src].</span>")
	else
		user.visible_message("<span class='warning'>[user] begins to wipe [H]'s lipstick off with \the [src].</span>", \
						 	 "<span class='notice'>You begin to wipe off [H]'s lipstick.</span>")
		if(!do_after(user, 20, TRUE, 5, BUSY_ICON_FRIENDLY) && user.Adjacent(H))
			return
		user.visible_message("<span class='notice'>[user] wipes [H]'s lipstick off with \the [src].</span>", \
							 "<span class='notice'>You wipe off [H]'s lipstick.</span>")
	H.lip_style = null
	H.update_body()

/obj/item/paper/proc/addtofield(id, text, links = 0)
	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(locid < 15)
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart == 0)
			return	//No field found with matching id

		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		updateinfolinks()

/obj/item/paper/proc/updateinfolinks()
	info_links = info
	for(var/i in 1 to min(fields, 15))
		addtofield(i, "<font face=\"[PEN_FONT]\"><A href='?src=[REF(src)];write=[i]'>write</A></font>", 1)
	info_links = info_links + "<font face=\"[PEN_FONT]\"><A href='?src=[REF(src)];write=end'>write</A></font>"

/obj/item/paper/proc/clearpaper()
	info = null
	stamps = null
	LAZYCLEARLIST(stamped)
	LAZYCLEARLIST(logos)
	cut_overlays()
	image_threshold = initial(image_threshold)
	updateinfolinks()
	update_icon()

/obj/item/paper/proc/parsepencode(t, obj/item/pen/P, mob/user, iscrayon = FALSE)
	if(length(t) < 1)		//No input means nothing needs to be parsed
		return

	if(iscrayon)
		var/obj/item/toy/crayon/C = P
		var/tint = C.colour

	t = parsemarkdown(t, user, iscrayon, tint, P)

	if(!iscrayon)
		t = "<font face=\"[P.font]\" color=[P.colour]>[t]</font>"
	else
		t = "<font face=\"[CRAYON_FONT]\" color=[tint]><b>[t]</b></font>"

	// Count the fields
	var/laststart = 1
	while(fields < 15)
		var/i = findtext(t, "<span class=\"paper_field\">", laststart)
		if(i == 0)
			break
		laststart = i+1
		fields++

	return t

/obj/item/paper/proc/reload_fields() // Useful if you made the paper programicly and want to include fields. Also runs updateinfolinks() for you.
	fields = 0
	var/laststart = 1
	while(fields < 15)
		var/i = findtext(info, "<span class=\"paper_field\">", laststart)
		if(i == 0)
			break
		laststart = i+1
		fields++
	updateinfolinks()


/obj/item/paper/proc/openhelp(mob/user)
	user << browse({"<HTML><HEAD><TITLE>Paper Help</TITLE></HEAD>
	<BODY>
		You can use backslash (\\) to escape special characters.<br>
		<br>
		<b><center>Crayon&Pen commands</center></b><br>
		<br>
		# text : Defines a header.<br>
		|text| : Centers the text.<br>
		**text** : Makes the text <b>bold</b>.<br>
		*text* : Makes the text <i>italic</i>.<br>
		^text^ : Increases the <font size = \"4\">size</font> of the text.<br>
		%s : Inserts a signature of your name in a foolproof way.<br>
		%f : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		%d : Inserts a timestamp of the current (ingame) year, month and day.
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		((text)) : Decreases the <font size = \"1\">size</font> of the text.<br>
		* item : An unordered list item.<br>
		&nbsp;&nbsp;* item: An unordered list child item.<br>
		--- : Adds a horizontal rule.
	</BODY></HTML>"}, "window=paper_help")


/obj/item/paper/Topic(href, href_list)
	. = ..()
	var/literate = usr.is_literate()
	if(!usr.incapacitated || !Adjacent(usr) || literate)
		return

	if(href_list["help"])
		openhelp(usr)
		return
	if(href_list["write"])
		var/id = href_list["write"]
		var/t =  stripped_multiline_input("Enter what you want to write:", "Write", no_trim = TRUE)
		if(!t || usr.incapacitated || !Adjacent(usr) || literate)
			return
		var/obj/item/i = usr.get_active_held_item()	//Check to see if he still got that darn pen, also check if he's using a crayon or pen.
		var/iscrayon = FALSE
		if(!istype(i, /obj/item/pen))
			if(!istype(i, /obj/item/toy/crayon))
				return
			iscrayon = TRUE

		if(!in_range(src, usr) && loc != usr && !istype(loc, /obj/item/clipboard) && loc.loc != usr && usr.get_active_held_item() != i)	//Some check to see if he's allowed to write
			return

		log_paper("[key_name(usr)] writing to paper [t]")
		t = parsepencode(t, i, usr, iscrayon) // Encode everything from pencode to html

		if(t != null)	//No input from the user means nothing needs to be added
			if(id != "end")
				addtofield(text2num(id), t) // He wants to edit a field, let him.
			else
				info += t // Oh, he wants to edit to the end of the file, let him.
				updateinfolinks()
			usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links]<HR>[stamps]</BODY><div align='right'style='position:fixed;bottom:0;font-style:bold;'><A href='?src=[REF(src)];help=1'>\[?\]</A></div></HTML>", "window=[name]") // Update the window
			update_icon()


/obj/item/paper/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = ..()

	if(resistance_flags & ON_FIRE)
		return

	if(P.is_hot())
		if((CLUMSY in user.mutations) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_them()]self!</span>", \
								"<span class='userdanger'>You miss the paper and accidentally light yourself on fire!</span>")
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(in_range(user, src)) //to prevent issues as a result of telepathically lighting a paper
			burnpaper(P, user)
		return

	if(istype(P, /obj/item/paper) || istype(P, /obj/item/photo))
		if (istype(P, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = P
			if (!C.iscopy && !C.copied)
				to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
				add_fingerprint(user)
				return
		if(loc != user)
			return
		var/obj/item/paper_bundle/B = new(get_turf(user))
		if (name != "paper")
			B.name = name
		else if (P.name != "paper" && P.name != "photo")
			B.name = P.name
		user.dropItemToGround(P)
		user.dropItemToGround(src)
		to_chat(user, "<span class='notice'>You clip [P] to [src].</span>")
		B.attach_doc(src, user, TRUE)
		B.attach_doc(P, user, TRUE)
		user.put_in_hands(B)

	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		if(is_blind(user))
			to_chat(user, "<span class='warning'>You can't see enough to read or write</span>)
			return
		if(user.is_literate())
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links]<HR>[stamps]</BODY><div align='right'style='position:fixed;bottom:0;font-style:bold;'><A href='?src=[REF(src)];help=1'>\[?\]</A></div></HTML>", "window=[name]")
			return
		else
			to_chat(user, "<span class='notice'>You don't know how to read or write.</span>")
			return

	else if(istype(P, /obj/item/stamp))
		var/obj/item/stamp/S = P

		if(!in_range(src, user))
			return

		(image_threshold < 1)
			to_chat(user, "<span class='notice'>You stamp the overly cluttered [name] with your rubber stamp to no effect.</span>")
		else
			var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/simple/paper)
			if (isnull(stamps))
				stamps = sheet.css_tag()
			stamps += sheet.add_icon_markdown(S.icon_state, S.stampcolor)
			var/image/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_[S.icon_state]")
			stampoverlay.color = S.stampcolor
			switch(S.stamp_flags)
				if(STAMP_CIRCULAR)
					stampoverlay.pixel_x = rand(-2, 0)
					stampoverlay.pixel_y = rand(-1, 2)
				if(STAMP_RECTANGULAR)
					stampoverlay.pixel_x = rand(-2, 2)
					stampoverlay.pixel_y = rand(-3, 2)
			LAZYADD(stamped, S.icon_state)
			stamped[S.icon_state] = S.stampcolor
			add_overlay(stampoverlay)
			to_chat(user, "<span class='notice'>You stamp \the [src] with your rubber stamp.</span>")
		playsound(loc, 'sound/effects/stamp.ogg', 50, 1)
	add_fingerprint(user)

/*
/obj/item/paper/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if(!(resistance_flags & FIRE_PROOF))
		info = "[stars(info)]"
		update_icon()

/obj/item/paper/flamer_fire_act()
	fire_act() */

/obj/item/paper/can_bundle(mob/user)
	return TRUE

/obj/item/paper/photocopy_act(obj/machinery/photocopier/P, mob/user)
	var/cost = P.greytoggle ? 1 : 2
	if(P.toner < cost)
		return FALSE
	var/tonality = P.greytoggle ? null : P.toner > 10 ? "#101010" : "#808080"
	copy_paper(loc, obj/item/paper, tonality)
	P.toner = min(P.toner - cost, 0)
	return TRUE

/obj/item/paper/photocopier/photocopier_insertion(obj/machinery/photocopier/P)
	. = ..()
	if(.)
		P.copy = src

/obj/item/paper/proc/copy_paper(atom/newloc, newtype = /obj/item/paper, newcolor)
	var/obj/item/paper/C = new newtype(newloc)
	var/copycontents = html_decode(info)
	if(newcolor)
		copycontents = replacetext(copycontents, regex("(?=<font face=\\\".*\\\"\\s)?color=\\\".*\\\"", "igm"), "color=[newcolor]")	//breaks the existing color tag. Now regex flavored.
	C.info = copycontents
	C.name = "Copy - [c.name]"
	C.fields = fields
	C.stamps = stamps
	C.copy_overlays(copy, TRUE)
	C.stamped = stamped?.Copy()
	if(newcolor)
		var/datum/asset/spritesheet/simple/paper/P = get_asset_datum(/datum/asset/spritesheet/simple/paper)
		var/counter = 1
		if(stamps && stamped)
			if(isnull(C.stamps))
				C.stamps = P.css_tag()
			C.stamps += sheet.add_icon_markdown(stamped[counter++], newcolor)
		for(var/E in C.overlays)
			var/image/I = E
			I.color = newcolor
		for(var/O in logos)
			var/list/U = uniqueList(C.logos[O])
			for(var/tag in U)
				replacetext(C.info, P.icon_tag(tag), P.add_icon_markdown(O, newcolor, C))
	else
		C.stamps = stamps
		C.logos = logos?.Copy()
	C.updateinfolinks()
	C.update_icon()
	return C


/*
 * Construction paper
 */

/obj/item/paper/construction

/obj/item/paper/construction/Initialize()
	. = ..()
	color = pick("FF0000", "#33cc33", "#ffb366", "#551A8B", "#ff80d5", "#4d94ff")

/*
 * Natural paper
 */

/obj/item/paper/natural/Initialize()
	. = ..()
	color = "#FFF5ED"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"
	slot_flags = null

/obj/item/paper/crumpled/update_icon()
	return

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"