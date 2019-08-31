
//holographic weapons used by the holodeck.

/obj/item/weapon/holo
	damtype = HALLOSS

/obj/item/weapon/holo/esword
	desc = "May the force be within you. Sorta."
	icon_state = "sword0"
	force = 3.0
	throw_speed = 1
	throw_range = 5
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	flags_item = NOBLUDGEON
	var/active = 0
	var/sword_color

/obj/item/weapon/holo/esword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/holo/esword/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/holo/esword/New()
	if(!sword_color)
		sword_color = pick("red","blue","green","purple")
	..()

/obj/item/weapon/holo/esword/attack_self(mob/living/user as mob)
	active = !active
	if (active)
		force = 30
		icon_state = "sword[sword_color]"
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 25, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		icon_state = "sword0"
		w_class = WEIGHT_CLASS_SMALL
		playsound(user, 'sound/weapons/saberoff.ogg', 25, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand(0)
		H.update_inv_r_hand()

	return


/obj/item/weapon/holo/esword/green
	sword_color = "green"

/obj/item/weapon/holo/esword/red
	sword_color = "red"
