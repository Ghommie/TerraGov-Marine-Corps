/obj/item/paper_bundle
	name = "paper bundle"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 2
	throw_speed = 1
	layer = ABOVE_OBJ_LAYER
	attack_verb = list("bapped")
	var/page = 1    // current page
	var/list/pages  // Ordered list of pages as they are to be displayed. Can be different order than src.contents.

/obj/item/weapon/paper_bundle/proc/insert_sheet_at(mob/user, var/index, obj/item/S)
	if (!user.transferItemToLoc(S, src))
		return

	to_chat(user, "<span class='notice'>You add [S] to [src].</span>")
	pages.Insert(index, sheet)
	if(index <= page)
		page++

/obj/item/paper_bundle/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		show_content(user)
	else
		to_chat(user, "<span class='notice'>It is too far away.</span>")

/obj/item/weapon/paper_bundle/attack_self(mob/user as mob)
	show_content(user)
	add_fingerprint(user)
	update_icon()

/obj/item/paper_bundle/attackby(obj/item/I, mob/user)
	. = ..()
	if(istype(obj/item/paper)
		var/obj/item/paper/P = I
		if(!paper.can_bundle(user))
			return //non-paper or bundlable paper only
		insert_sheet_at(user, length(pages) + 1, I)
	else if(istype(I, /obj/item/photo))
		insert_sheet_at(user, length(pages) + 1, I)
	else if(I.is_hot())
		add_fingerprint(user)
		burnpaper(I, user)
		return
	else if(istype(I, /obj/item/paper_bundle))
		for(var/obj/O in I)
			O.forceMove(src)
			O.add_fingerprint(user)
			pages.Add(O)
			to_chat(user, "<span class='notice'>You add \the [W.name] to \the [name].</span>")
			qdel(I)
	else if(istype(I, /obj/item/tool/pen) || istype(I, /obj/item/toy/crayon))
			usr << browse("", "window=[name]") //Closes the dialog
		P = contents[page]
		P.attackby(W, user)

	update_icon()
	show_content(user)
	add_fingerprint(user)

/obj/item/weapon/paper_bundle/proc/show_content(mob/user)
	var/dat
	var/obj/item/I = pages[page]

	dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=[REF(src)];prev_page=1'>[page == 1 ? "Front" : "Previous Page"</A></DIV>"
	dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=[REF(src)];remove=1'>Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
	dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=[REF(src)];next_page=1'>[page == length(pages) : "Back" : "Next Page"]</A></DIV><BR><HR>"

	if(istype(I, /obj/item/paper))
		var/obj/item/weapon/paper/P = I
		dat+= "<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[P.readme(user)]</BODY></HTML>"
		show_browser(user, dat, "window=[name]")
	else if(istype(I, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/P = I
		dat += "<html><head><title>[P.name]</title></head><body style='overflow:hidden'>"
		dat += "<div> <img src='tmp_photo.png' width = '180'[P.scribble ? "<div> Written on the back:<br><i>[P.scribble]</i>" : ]</body></html>"
		user << browse_rsc(P.img, "tmp_photo.png")
		user << browse(user, jointext(dat, null), "window=[name]")

/obj/item/weapon/paper_bundle/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(!(istype(loc, /obj/item/weapon/folder) && !(src in usr.contents)) || !(loc in usr.contents)))
		to_chat(usr, "<span class='notice'>You need to hold it in hands!</span>")
		return
	var/obj/item/in_hand = usr.get_active_held_item()
	if(href_list["next_page"])
		if(in_hand && (istype(in_hand, /obj/item/paper) || istype(in_hand, /obj/item/photo)))
			insert_sheet_at(usr, page + 1, in_hand)
		else if(page != pages.len)
			page++
			playsound(loc, "pageturn", 50, 1)
	if(href_list["prev_page"])
		if(in_hand && (istype(in_hand, /obj/item/paper) || istype(in_hand, /obj/item/photo)))
			insert_sheet_at(usr, page, in_hand)
		else if(page > 1)
			page--
			playsound(loc, "pageturn", 50, 1)
	if(href_list["remove"])
		var/obj/item/weapon/W = pages[page]
		usr.put_in_hands(W)
		pages.Remove(pages[page])

		to_chat(usr, "<span class='notice'>You remove the [W.name] from the bundle.</span>")

		if(!length(pages))
			var/obj/item/paper/P = src[1]
			usr.drop_from_inventory(src)
			usr.put_in_hands(P)
			qdel(src)
			return
		page = min(page, length(pages))
		update_icon()

	updateUsrDialog()

/obj/item/weapon/paper_bundle/verb/rename()
	set name = "Rename bundle"
	set category = "Object"
	set src in usr

	if(usr.incapacitated() || !usr.is_literate())
		return
	if((CLUMSY in usr.mutations) && prob(25))
		to_chat(usr, "<span class='warning'>You cut yourself on the paper! Ahhhh! Ahhhhh!</span>")
		damageoverlaytemp = 9001
		flash_pain()
		return
	var/n_name = stripped_input(usr, "What would you like to label the bundle?", "Bundle Labelling", null, MAX_NAME_LEN)
	if((loc == usr && usr.stat == CONSCIOUS))
		name = "paper bundle[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)

/obj/item/paper_bundle/verb/remove_all()
	set name = "Loose bundle"
	set category = "Object"
	set src in usr

	to_chat(usr, "<span class='notice'>You loosen the bundle.</span>")
	for(var/obj/O in src)
		O.forceMove(usr.loc)
		O.add_fingerprint(usr)
	qdel(src)

/obj/item/weapon/paper_bundle/on_update_icon()
	var/obj/item/paper/P = pages[1]
	icon_state = P.icon_state
	overlays = P.overlays
	cut_underlays()
	var/i = 0
	var/photo = FALSE
	for(var/obj/O in src)
		var/image/I = image('icons/obj/bureaucracy.dmi')
		if(istype(O, /obj/item/paper))
			I.icon_state = O.icon_state
			I.pixel_x -= min(1*i, 2)
			I.pixel_y -= min(1*i, 2)
			pixel_x = min(0.5*i, 1)
			pixel_y = min(  1*i, 2)
			underlays += img
			i++
		else if(istype(O, /obj/item/photo))
			var/obj/item/photo/P = O
			img = P.tiny
			photo = TRUE
			overlays += img
	if(i>1)
		desc =  i > 1 ? "[i] papers clipped to each other." : "A single sheet of paper."
	if(photo)
		desc += "\nThere is a photo attached to it."
	overlays += image('icons/obj/bureaucracy.dmi', "clip")

