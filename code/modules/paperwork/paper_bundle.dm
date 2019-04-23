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

/obj/item/paper_bundle/proc/insert_sheet_at(mob/user, index, obj/item/S, skip_prep = FALSE)
	if(!skip_prep)
		if (!user.transferItemToLoc(S, src))
			return
		to_chat(user, "<span class='notice'>You add [S] to [src].</span>")
	pages.Insert(index, S)
	if(index <= page)
		page++

/obj/item/paper_bundle/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		ui_interact(user)
	else
		to_chat(user, "<span class='notice'>It is too far away.</span>")

/obj/item/paper_bundle/attack_self(mob/user)
	ui_interact(user)
	add_fingerprint(user)
	update_icon()

/obj/item/paper_bundle/attackby(obj/item/I, mob/user)
	. = ..()
	if(istype(I, /obj/item/paper))
		var/obj/item/paper/P = I
		if(!P.can_bundle(user))
			return
		insert_sheet_at(user, length(pages) + 1, I)
	else if(istype(I, /obj/item/photo))
		insert_sheet_at(user, length(pages) + 1, I)
	else if(I.heat_source > 400)
		add_fingerprint(user)
		burnpaper(I, user)
		return
	else if(istype(I, /obj/item/paper_bundle))
		var/counter = length(pages)
		for(var/A in I)
			insert_sheet_at(user, ++counter, A, TRUE)
		qdel(I)
		to_chat(user, "<span class='notice'>You merge the two paper bundles together.</span>")
	else if(istype(I, /obj/item/tool/pen) || istype(I, /obj/item/toy/crayon))
		usr << browse("", "window=[name]") //Closes the dialog
		var/obj/item/O = contents[page]
		O.attackby(I, user)

	update_icon()
	ui_interact(user)
	add_fingerprint(user)

/obj/item/paper_bundle/ui_interact(mob/user)
	var/obj/item/I = pages[page]
	var/dat = "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=[REF(src)];flip_page=1'>[page == 1 ? "Front" : "Previous Page"]</A></DIV>"
	dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=[REF(src)];remove=1'>Remove [(istype(I, /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
	dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=[REF(src)];flip_page=-1'>[page == length(pages) ? "Back" : "Next Page"]</A></DIV><BR><HR>"
	if(istype(I, /obj/item/paper))
		var/obj/item/paper/P = I
		dat+= "<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[P.readme(user)]</BODY></HTML>"
	else if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		dat += "<html><head><title>[P.name]</title></head><body style='overflow:hidden'>"
		dat += "<div> <img src='tmp_photo.png' width = '180'>[P.scribble ? "<div> Written on the back:<br><i>[P.scribble]</i>" : ""]</body></html>"
		user << browse_rsc(P.img, "tmp_photo.png")
	var/datum/browser/popup = new(user, "paperbundle", "<div align='center'>[name]</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "paperbundle")

/obj/item/paper_bundle/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(!(src in usr) && !(istype(loc, /obj/item/folder) && (loc in usr)))
		to_chat(usr, "<span class='notice'>You need to hold it in hands!</span>")
		return
	var/obj/item/in_hand = usr.get_active_held_item()
	if(href_list["flip_page"])
		if(in_hand && (istype(in_hand, /obj/item/paper) || istype(in_hand, /obj/item/photo)))
			insert_sheet_at(usr, page + 1, in_hand)
		else
			var/flipped_pages = text2num(href_list["move_page"])
			page = CLAMP(page + flipped_pages, 1, length(pages))
			playsound(loc, "pageturn", 50, 1)
	if(href_list["remove"])
		var/obj/item/I = pages[page]
		usr.put_in_hands(I)
		pages.Remove(pages[page])
		to_chat(usr, "<span class='notice'>You remove the [I.name] from the bundle.</span>")
		if(!length(pages))
			var/obj/item/paper/P = src[1]
			usr.temporarilyRemoveItemFromInventory(src)
			usr.put_in_hands(P)
			qdel(src)
			return
		page = min(page, length(pages))
		update_icon()

	updateUsrDialog()

/obj/item/paper_bundle/verb/rename()
	set name = "Rename bundle"
	set category = "Object"
	set src in usr

	if(usr.incapacitated() || !usr.is_literate())
		return
	if((CLUMSY in usr.mutations) && prob(25))
		to_chat(usr, "<span class='warning'>You cut yourself on the paper! Ahhhh! Ahhhhh!</span>")
		usr.flash_pain()
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

/obj/item/paper_bundle/update_icon()
	var/obj/item/paper/P = pages[1]
	add_overlay(P)
	underlays.Cut()
	var/i = 0
	var/photo = FALSE
	for(var/obj/O in src)
		if(istype(O, /obj/item/paper))
			var/mutable_appearance/I = mutable_appearance(O)
			I.pixel_x -= min(1 * i, 2)
			I.pixel_y -= min(1 * i, 2)
			pixel_x = min(0.5 * i, 1)
			pixel_y = min(1 * i, 2)
			underlays.Add(I)
			i++
		else if(!photo && istype(O, /obj/item/photo))
			var/obj/item/photo/N = O
			photo = TRUE
			add_overlay(N.tiny)
	desc =  i > 1 ? "[i] papers clipped to each other." : "A single sheet of paper."
	if(photo)
		desc += "\nThere is a photo attached to it."
	add_overlay(image('icons/obj/bureaucracy.dmi', "clip"))
