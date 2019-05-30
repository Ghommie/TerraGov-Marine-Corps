/obj/machinery/computer/aifixer
	name = "AI System Integrity Restorer"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "ai-fixer"
	circuit = /obj/item/circuitboard/computer/aifixer
	req_one_access = list(ACCESS_CIVILIAN_ENGINEERING)
	var/mob/living/silicon/ai/occupant = null
	var/active = 0

/obj/machinery/computer/aifixer/New()
	src.overlays += image('icons/obj/machines/computer.dmi', "ai-fixer-empty")


/obj/machinery/computer/aifixer/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "This terminal isn't functioning right now, get it working!")
		return
	if(istype(I, /obj/item/aicard))
		var/obj/item/aicard/AI = I
		AI.transfer_ai("AIFIXER", "AICARD", src, user)

/obj/machinery/computer/aifixer/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/aifixer/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/aifixer/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.set_interaction(src)
	var/dat

	if (src.occupant)
		var/laws
		dat += "Stored AI: [src.occupant.name]<br>System integrity: [(src.occupant.health+100)/2]%<br>"

		for (var/law in occupant.laws.ion)
			if(law)
				laws += "[ionnum()]: [law]<BR>"

		if (src.occupant.laws.zeroth)
			laws += "0: [occupant.laws.zeroth]<BR>"

		var/number = 1
		for (var/index = 1, index <= occupant.laws.inherent.len, index++)
			var/law = occupant.laws.inherent[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		for (var/index = 1, index <= occupant.laws.supplied.len, index++)
			var/law = occupant.laws.supplied[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		dat += "Laws:<br>[laws]<br>"

		if (src.occupant.stat == 2)
			dat += "<b>AI nonfunctional</b>"
		else
			dat += "<b>AI functional</b>"
		if (!src.active)
			dat += {"<br><br><A href='byond://?src=\ref[src];fix=1'>Begin Reconstruction</A>"}
		else
			dat += "<br><br>Reconstruction in process, please wait.<br>"
	dat += {" <A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	var/datum/browser/popup = new(user, "computer", "<div align='center'>AI System Integrity Restorer</div>", 400, 500)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "computer")


/obj/machinery/computer/aifixer/process()
	if(..())
		src.updateDialog()
		return

/obj/machinery/computer/aifixer/Topic(href, href_list)
	if(..())
		return
	if (href_list["fix"])
		src.active = 1
		src.overlays += image('icons/obj/machines/computer.dmi', "ai-fixer-on")
		while (src.occupant.health < 100)
			src.occupant.adjustOxyLoss(-1)
			src.occupant.adjustFireLoss(-1)
			src.occupant.adjustToxLoss(-1)
			src.occupant.adjustBruteLoss(-1)
			src.occupant.updatehealth()
			if (src.occupant.health >= 0 && src.occupant.stat == DEAD)
				src.occupant.stat = CONSCIOUS
				src.occupant.lying = 0
				GLOB.dead_mob_list -= src.occupant
				GLOB.alive_mob_list += src.occupant
				occupant.reload_fullscreens()
				src.overlays -= image('icons/obj/machines/computer.dmi', "ai-fixer-404")
				src.overlays += image('icons/obj/machines/computer.dmi', "ai-fixer-full")
				src.occupant.add_ai_verbs()
			src.updateUsrDialog()
			sleep(10)
		src.active = 0
		src.overlays -= image('icons/obj/machines/computer.dmi', "ai-fixer-on")


		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/aifixer/update_icon()
	..()
	// Broken / Unpowered
	if((machine_stat & BROKEN) || (machine_stat & NOPOWER))
		overlays.Cut()

	// Working / Powered
	else
		if (occupant)
			switch (occupant.stat)
				if (0)
					overlays += image('icons/obj/machines/computer.dmi', "ai-fixer-full")
				if (2)
					overlays += image('icons/obj/machines/computer.dmi', "ai-fixer-404")
		else
			overlays += image('icons/obj/machines/computer.dmi', "ai-fixer-empty")
