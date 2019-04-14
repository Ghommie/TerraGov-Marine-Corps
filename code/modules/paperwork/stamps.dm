/obj/item/stamp
	name = "\improper GRANTED rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-ok"
	item_state = "stamp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	matter = list("metal" = 60)
	attack_verb = list("stamped")

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead.</span>")
	return (OXYLOSS)

/obj/item/stamp/qm
	name = "quartermaster's rubber stamp"
	icon_state = "stamp-qm"

/obj/item/stamp/law
	name = "law office's rubber stamp"
	icon_state = "stamp-law"

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"

/obj/item/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"

/obj/item/tool/stamp/internalaffairs
	name = "internal affairs rubber stamp"
	icon_state = "stamp-intaff"

/obj/item/tool/stamp/centcomm
	name = "centcomm rubber stamp"
	icon_state = "stamp-cent"

/obj/item/tool/stamp/tgmc
	name = "\improper TGMC rubber stamp"
	desc = "A sturdy, adorned rubber stamp for stamping very important documents."
	icon_state = "stamp-tgmc"
	force = 5
	throwforce = 6
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/tool/stamp/ro
	name = "requisition officer's rubber stamp"
	icon_state = "stamp-ro"

/obj/item/tool/stamp/mp
	name = "chief master at arms' rubber stamp"
	icon_state = "stamp-mp"

/obj/item/stamp/attack_paw(mob/user)
	return attack_hand(user)