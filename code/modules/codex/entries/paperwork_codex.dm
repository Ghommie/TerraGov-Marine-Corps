/datum/codex_entry/pen
	associated_paths = list(/obj/item/tool/pen)
	mechanics_text = {"This is an item for writing down your thoughts, on paper or elsewhere.
<br>You can use backslash (\\) to escape special characters.
<br>The following special commands are available:
<br>
<br># text : Defines a header.
<br>|text| : Centers the text.
<br>**text** : Makes the text <b>bold</b>.
<br>*text* : Makes the text <i>italic</i>.
<br>^text^ : Increases the <font size = \"4\">size</font> of the text.
<br>%s : Inserts a signature of your name in a foolproof way.
<br>%f : Inserts an invisible field which lets you start type from there. Useful for forms.
<br>%d : Inserts a timestamp of the current (ingame) year, month and day.
<br>%logo : Inserts an outline of the TMGC logo.
<br>%ntlogo : Inserts an outline of the NT logo.
<br>%zippylogo : Inserts an outline of the Zippy Pizza logo.
<br>
<br><b><center>Pen exclusive commands</center></b>
<br>((text)) : Decreases the <font size = \"1\">size</font> of the text.
<br>* item : An unordered list item.
<br>&nbsp;&nbsp;* item: An unordered list child item.
<br>--- : Adds a horizontal rule."}
