
function TextInput(default$,X#,Y#)
	ReturnValue$ as string
	tmpEditBox as integer
	tmpEditBox = createSDtxbox(default$,X#,Y#,3)
	SetEditBoxFocus(tmpEditBox,1)

	Repeat
		Sync()
	Until GetEditBoxHasFocus( tmpEditBox ) =0

	ReturnValue$ = GetEditBoxText(tmpEditBox)

	DeleteEditBox(tmpEditBox)

endfunction ReturnValue$
