
function TextInput(default$,X#,Y#)
	ReturnValue$ as string
	tmpEditBox as integer
	tmpEditBox = CreateEditBox()
	SetEditBoxPosition(tmpEditBox,X#,Y#)
	SetEditBoxText(tmpEditBox,default$)
	
	SetEditBoxSize(tmpEditBox,350,50)
	SetEditBoxTextSize( tmpEditBox, 40 )
	//Enter 'quit' to End
	SetEditBoxFocus(tmpEditBox,1)

	Repeat
	//	Sync()
	Until GetEditBoxHasFocus( tmpEditBox ) =0

	ReturnValue$ = GetEditBoxText(tmpEditBox)

	DeleteEditBox(tmpEditBox)

endfunction ReturnValue$
