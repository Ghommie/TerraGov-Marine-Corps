/obj/screen/human/equip
	name = "equip"
	icon_state = "act_equip"
	screen_loc = ui_swaphand1
	layer = ABOVE_HUD_LAYER

/obj/screen/human/equip/Click()
	if(ismecha(usr.loc) || istype(usr.loc, /obj/vehicle/multitile/root/cm_armored)) // stops inventory actions in a mech
		return 1
	var/mob/living/carbon/human/H = usr
	H.quick_equip()

/datum/hud/human/New(mob/living/carbon/human/owner, ui_style='icons/mob/screen/White.dmi', ui_color = "#ffffff", ui_alpha = 255)
	..()
	var/datum/hud_data/hud_data
	if(!istype(owner))
		hud_data = new()
	else
		hud_data = owner.species.hud

	if(hud_data.icon)
		ui_style = hud_data.icon

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	// Draw the various inventory equipment slots.
	var/has_hidden_gear
	for(var/gear_slot in hud_data.gear)

		inv_box = new /obj/screen/inventory()
		inv_box.icon = ui_style
		inv_box.color = ui_color
		inv_box.alpha = ui_alpha

		var/list/slot_data =  hud_data.gear[gear_slot]
		inv_box.name =        gear_slot
		inv_box.screen_loc =  slot_data["loc"]
		inv_box.slot_id =     slot_data["slot"]
		inv_box.icon_state =  slot_data["state"]

		if(slot_data["toggle"])
			toggleable_inventory += inv_box
			has_hidden_gear = 1
		else
			static_inventory += inv_box

	if(has_hidden_gear)
		using = new /obj/screen/toggle_inv()
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

	// Draw the attack intent dialogue.
	if(hud_data.has_a_intent)

		using = new /obj/screen/act_intent/corner()
		using.icon_state = owner.a_intent
		using.alpha = ui_alpha
		static_inventory += using
		action_intent = using



	if(hud_data.has_m_intent)
		using = new /obj/screen/mov_intent()
		using.icon = ui_style
		using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using
		move_intent = using

	if(hud_data.has_drop)
		using = new /obj/screen/drop()
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		hotkeybuttons += using

	if(hud_data.has_hands)

		using = new /obj/screen/human/equip
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

		inv_box = new /obj/screen/inventory/hand/right()
		inv_box.icon = ui_style
		if(owner && !owner.hand)	//This being 0 or null means the right hand is in use
			inv_box.add_overlay("hand_active")
		inv_box.slot_id = SLOT_R_HAND
		inv_box.color = ui_color
		inv_box.alpha = ui_alpha
		r_hand_hud_object = inv_box
		static_inventory += inv_box

		inv_box = new /obj/screen/inventory/hand()
		inv_box.setDir(EAST)
		inv_box.icon = ui_style
		if(owner && owner.hand)	//This being 1 means the left hand is in use
			inv_box.add_overlay("hand_active")
		inv_box.slot_id = SLOT_L_HAND
		inv_box.color = ui_color
		inv_box.alpha = ui_alpha
		l_hand_hud_object = inv_box
		static_inventory += inv_box

		using = new /obj/screen/swap_hand/human()
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

		using = new /obj/screen/swap_hand/right()
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

	if(hud_data.has_resist)
		using = new /obj/screen/resist()
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		hotkeybuttons += using

	if(hud_data.has_throw)
		throw_icon = new /obj/screen/throw_catch()
		throw_icon.icon = ui_style
		throw_icon.color = ui_color
		throw_icon.alpha = ui_alpha
		hotkeybuttons += throw_icon

		pull_icon = new /obj/screen/pull()
		pull_icon.icon = ui_style
		pull_icon.update_icon(owner)
		hotkeybuttons += pull_icon


	if(hud_data.has_internals)
		internals = new /obj/screen/internals()
		infodisplay += internals


	if(hud_data.has_warnings)
		oxygen_icon = new /obj/screen/oxygen()
		infodisplay += oxygen_icon

		toxin_icon = new /obj/screen()
		toxin_icon.icon_state = "tox0"
		toxin_icon.name = "toxin"
		toxin_icon.screen_loc = ui_toxin
		infodisplay += toxin_icon

		fire_icon = new /obj/screen/fire()
		infodisplay += fire_icon

		healths = new /obj/screen/healths()
		infodisplay += healths

	if(hud_data.has_pressure)
		pressure_icon = new /obj/screen()
		pressure_icon.icon_state = "pressure0"
		pressure_icon.name = "pressure"
		pressure_icon.screen_loc = ui_pressure
		infodisplay += pressure_icon

	if(hud_data.has_bodytemp)
		bodytemp_icon = new /obj/screen/bodytemp()
		infodisplay += bodytemp_icon


	if(hud_data.has_nutrition)
		nutrition_icon = new /obj/screen()
		nutrition_icon.icon_state = "nutrition0"
		nutrition_icon.name = "nutrition"
		nutrition_icon.screen_loc = ui_nutrition
		infodisplay += nutrition_icon

	rest_icon = new /obj/screen/rest()
	rest_icon.icon = ui_style
	rest_icon.update_icon(owner)
	static_inventory += rest_icon

	//squad leader locator
	SL_locator = new /obj/screen/SL_locator
	infodisplay += SL_locator

	use_attachment = new /obj/screen/firearms/attachment()
	static_inventory += use_attachment

	toggle_raillight = new /obj/screen/firearms/flashlight()
	static_inventory += toggle_raillight

	eject_mag = new /obj/screen/firearms/magazine()
	static_inventory += eject_mag

	/obj/screen/firearms/burstfire()
	static_inventory += toggle_burst

	unique_action = new /obj/screen/firearms/unique()
	static_inventory += unique_action

	zone_sel = new /obj/screen/zone_sel()
	zone_sel.icon = ui_style
	zone_sel.color = ui_color
	zone_sel.alpha = ui_alpha
	zone_sel.update_icon(owner)
	static_inventory += zone_sel

	ammo = new /obj/screen/ammo()


/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 0
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 1


//Used for new human mobs created by cloning/goleming/etc.
/mob/living/carbon/human/proc/set_cloned_appearance()
	f_style = "Shaved"
	if(dna.species == "Human") //no more xenos losing ears/tentacles
		h_style = pick("Bedhead", "Bedhead 2", "Bedhead 3")
	undershirt = GLOB.undershirt_t.Find("None")
	if(gender == MALE)
		underwear = GLOB.underwear_m.Find("None")
	else
		underwear = GLOB.underwear_f.Find("None")
	regenerate_icons()



/datum/hud/human/hidden_inventory_update()
	if(!mymob) return
	var/mob/living/carbon/human/H = mymob
	if(H.species && H.species.hud && !H.species.hud.gear.len)
		inventory_shown = FALSE
		return //species without inv slots don't show items.
	if(inventory_shown && hud_shown)
		if(H.shoes)
			H.shoes.screen_loc = ui_shoes
			H.client.screen += H.shoes
		if(H.gloves)
			H.gloves.screen_loc = ui_gloves
			H.client.screen += H.gloves
		if(H.wear_ear)
			H.wear_ear.screen_loc = ui_wear_ear
			H.client.screen += H.wear_ear
		if(H.glasses)
			H.glasses.screen_loc = ui_glasses
			H.client.screen += H.glasses
		if(H.w_uniform)
			H.w_uniform.screen_loc = ui_iclothing
			H.client.screen += H.w_uniform
		if(H.wear_suit)
			H.wear_suit.screen_loc = ui_oclothing
			H.client.screen += H.wear_suit
		if(H.wear_mask)
			H.wear_mask.screen_loc = ui_mask
			H.client.screen += H.wear_mask
		if(H.head)
			H.head.screen_loc = ui_head
			H.client.screen += H.head
	else
		if(H.shoes)
			H.shoes.screen_loc = null
		if(H.gloves)
			H.gloves.screen_loc = null
		if(H.wear_ear)
			H.wear_ear.screen_loc = null
		if(H.glasses)
			H.glasses.screen_loc = null
		if(H.w_uniform)
			H.w_uniform.screen_loc = null
		if(H.wear_suit)
			H.wear_suit.screen_loc = null
		if(H.wear_mask)
			H.wear_mask.screen_loc = null
		if(H.head)
			H.head.screen_loc = null


/datum/hud/human/persistant_inventory_update()
	if(!mymob) return
	var/mob/living/carbon/human/H = mymob
	if(hud_shown)
		if(!H.species || !H.species.hud || H.species.hud.gear.len) //species without inv slots don't show items.
			if(H.s_store)
				H.s_store.screen_loc = ui_sstore1
				H.client.screen += H.s_store
			if(H.wear_id)
				H.wear_id.screen_loc = ui_id
				H.client.screen += H.wear_id
			if(H.belt)
				H.belt.screen_loc = ui_belt
				H.client.screen += H.belt
			if(H.back)
				H.back.screen_loc = ui_back
				H.client.screen += H.back
			if(H.l_store)
				H.l_store.screen_loc = ui_storage1
				H.client.screen += H.l_store
			if(H.r_store)
				H.r_store.screen_loc = ui_storage2
				H.client.screen += H.r_store
	else
		if(H.s_store)
			H.s_store.screen_loc = null
		if(H.wear_id)
			H.wear_id.screen_loc = null
		if(H.belt)
			H.belt.screen_loc = null
		if(H.back)
			H.back.screen_loc = null
		if(H.l_store)
			H.l_store.screen_loc = null
		if(H.r_store)
			H.r_store.screen_loc = null

	if(hud_version != HUD_STYLE_NOHUD)
		if(H.r_hand)
			H.r_hand.screen_loc = ui_rhand
			H.client.screen += H.r_hand
		if(H.l_hand)
			H.l_hand.screen_loc = ui_lhand
			H.client.screen += H.l_hand
	else
		if(H.r_hand)
			H.r_hand.screen_loc = null
		if(H.l_hand)
			H.l_hand.screen_loc = null



/mob/living/carbon/human/create_hud()
	if(client && !hud_used)
		var/ui_style = ui_style2icon(client.prefs.ui_style)
		var/ui_color = client.prefs.ui_style_color
		var/ui_alpha = client.prefs.ui_style_alpha
		hud_used = new /datum/hud/human(src, ui_style, ui_color, ui_alpha)
