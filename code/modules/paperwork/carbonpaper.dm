/obj/item/paper/carbon
	name = "paper"
	icon_state = "paper_stack"
	item_state = "paper"
	var/copied = FALSE
	var/iscopy = FALSE

/obj/item/paper/carbon/update_icon()
	icon_state = iscopy ? "cpaper" : copied ? "paper" : "paper_stack"
	if(info)
		icon_state += "_words"

/obj/item/paper/carbon/verb/removecopy()
	set name = "Remove carbon-copy"
	set category = "Object"
	set src in usr

	if (!copied)
		var/obj/item/paper/carbon/c = src
		var/copycontents = html_decode(c.info)
		var/obj/item/paper/carbon/copy = new /obj/item/paper/carbon (usr.loc)
		copycontents = replacetext(copycontents, regex("(?=<font face=\"(\\w*|\\s*)\"\\s)color=\"(\\w*|\\s*)\""), "")	//breaks the existing color tag, since we need to retain the innermost tag. Now regex flavored.
		copy.info += "[copycontents]</font>"
		copy.name = "Copy - [c.name]"
		copy.fields = c.fields
		copy.updateinfolinks()
		to_chat(usr, "<span class='notice'>You tear off the carbon-copy!</span>")
		c.copied = TRUE
		copy.iscopy = TRUE
		copy.update_icon()
		c.update_icon()
	else
		to_chat(usr, "There are no more carbon copies attached to this paper!")