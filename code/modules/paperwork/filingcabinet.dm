/* Filing cabinets!
 * Contains:
 *		Filing Cabinets
 *		Security Record Cabinets
 *		Medical Record Cabinets
 *		Employment Contract Cabinets
 */


/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE
	var/list/can_hold = list(
		/obj/item/paper,
		/obj/item/folder,
		/obj/item/photo,
		/obj/item/paper_bundle)

/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"

/obj/structure/filingcabinet/chestdrawer/wheeled
	name = "rolling chest drawer"
	desc = "A small cabinet with drawers. This one has wheels!"
	anchored = FALSE

/obj/structure/filingcabinet/tall
	icon_state = "tallcabinet"

/obj/structure/filingcabinet/wall
	name = "wall-mounted filing cabinet"
	desc = "A filing cabinet installed into a cavity in the wall to save space. Wow!"
	icon = 'icons/obj/wallframes.dmi'
	icon_state = "wallcabinet"
	pixel_x = -16
	pixel_y = -16
	density = FALSE

/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/item/I in loc)
			if(is_type_in_list(I, can_hold))
				I.forceMove(src)

/obj/structure/filingcabinet/wall/Initialize(mapload)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_y = -32
		if(SOUTH)
			pixel_y = 32
		if(EAST)
			pixel_x = -32
		if(WEST)
			pixel_x = 32

/obj/structure/filingcabinet/attackby(obj/item/P as obj, mob/user as mob)
	if(is_type_in_list(P, can_hold))
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		add_fingerprint(user)
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		flick("[initial(icon_state)]-open",src)
		updateUsrDialog()
	else if(iswrench(P))
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
	else if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>You can't put [P] in [src]!</span>")
	else
		return ..()

/obj/structure/filingcabinet/attack_hand(mob/user)
	ui_interact(user)

/obj/structure/filingcabinet/attack_ai(mob/user)
	ui_interact(user)

/obj/structure/filingcabinet/attack_paw(mob/user)
	ui_interact(user)

/obj/structure/filingcabinet/ui_interact(mob/user)
	. = ..()
	if(!length(contents))
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return

	var/dat = "<center><table>"
	for(i in 1 to length(contents))
		var/obj/item/P = contents[i]
		dat += "<tr><td><a href='?src=[REF(src)];retrieve=[REF(P)]'>[P.name]</a></td></tr>"
	dat += "</table></center>"
	var/datum/browser/popup = new(user, "filingcabinet", "<div align='center'>[name]</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "copier")

/obj/structure/filingcabinet/Topic(href, href_list)
	if(!user.Adjacent() || user.incapacitated())
		return
	if(href_list["retrieve"])
		usr << browse("", "window=filingcabinet") // Close the menu
		var/obj/item/P = locate(href_list["retrieve"]) in src //contents[retrieveindex]
		if(istype(P))
			usr.put_in_hands(P)
			updateUsrDialog()
			flick("[initial(icon_state)]-open",src)


/obj/structure/filingcabinet/attack_tk(mob/user)
	if(anchored)
		attack_self_tk(user)
	else
		..()

/obj/structure/filingcabinet/attack_self_tk(mob/user)
	if(length(contents))
		if(prob(40 + length(contents) * 5))
			var/obj/item/I = pick(contents)
			I.forceMove(loc)
			if(prob(25))
				step_rand(I)
			to_chat(user, "<span class='notice'>You pull \a [I] out of [src] at random.</span>")
			return
	to_chat(user, "<span class='notice'>You find nothing in [src].</span>")

#define CAT_SECURITY	(1<<0)
#define CAT_MEDICAL		(1<<1)

/obj/structure/filingcabinet/records
	desc = "A large cabinet with drawers, commonly used to store records of each crewmember."
	var/category

/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	if(!mapload)
		populate()
	GLOB.record_cabinets += src

/obj/structure/fillingcabinet/Destroy()
	GLOB.record_cabinets -= src
	return ..()

/obj/structure/filingcabinet/records/proc/populate()
	for(var/datum/data/record/G in GLOB.datacore.general)
		sort_record(G)

/obj/structure/filingcabinet/records/proc/sort_record(datum/data/record/G)
	var/list/recordkeepers
	if(categories & CAT_SECURITY)
		recordkeeper[CAT_SECURITY] = list(GLOB.datacore.security)
	if(categories & CAT_MEDICAL)
		recordkeeper[CAT_MEDICAL] = list(GLOB.datacore.medical)
	var/item/folder/F
	if(length(recordkeeper) > 1)
		F = new(src)
		F.name = "folder - '[G.fields["name"]]'"
	for(var/L in recordkeepers)
		var/list/holder = L
		var/datum/data/record/R = find_record("name", G.fields["name"], recordkeepers[holder])
		if(!R)
			continue
		add_record(G, R, holder, F)

/obj/structure/filingcabiner/records/proc/add_record(datum/data/record/G, datum/data/record/R, holder, item/folder/F)
	var/obj/item/paper/P = new /obj/item/paper(F ? F : src)
	switch(holder)
		if(CAT_MEDICAL)
			P.name = "paper - '[G.fields["name"]] (Medical)'"
			P.info = "<CENTER><B>Medical Record</B></CENTER><BR>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"
			P.info += "<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: [R.fields["b_type"]]<BR>\nDNA: [R.fields["b_dna"]]<BR>\n<BR>\nMinor Disabilities: [R.fields["mi_dis"]]<BR>\nDetails: [R.fields["mi_dis_d"]]<BR>\n<BR>\nMajor Disabilities: [R.fields["ma_dis"]]<BR>\nDetails: [R.fields["ma_dis_d"]]<BR>\n<BR>\nAllergies: [R.fields["alg"]]<BR>\nDetails: [R.fields["alg_d"]]<BR>\n<BR>\nCurrent Diseases: [R.fields["cdi"]] (per disease info placed in log/comment section)<BR>\nDetails: [R.fields["cdi_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[R.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
		if(CAT_SECURITY)
			P.name = "paper - '[G.fields["name"]] (Security)'"
			P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"
			P.info += "<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: [R.fields["criminal"]]<BR>\n<BR>\nMinor Crimes: [R.fields["mi_crim"]]<BR>\nDetails: [R.fields["mi_crim_d"]]<BR>\n<BR>\nMajor Crimes: [R.fields["ma_crim"]]<BR>\nDetails: [R.fields["ma_crim_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[R.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
	comment_field(G, R, P)

/obj/structure/filingcabinet/records/proc/comment_field(datum/data/record/G, datum/data/record/R, obj/item/paper/P)
	var/counter = 1
	while(S.fields["com_[counter]"])
		P.info += "[S.fields["com_[counter]"]]<BR>"
		counter++
	P.info += "</TT>"


/obj/structure/filingcabinet/records/security
	category = CAT_SECURITY

/obj/structure/filingcabinet/records/medical
	category = CAT_MEDICAL


#undef CAT_SECURITY
#undef CAT_MEDICAL