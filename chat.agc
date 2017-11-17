
function TextInput(default$,X#,Y#)
	ReturnValue$ as string
	tmpEditBox as integer
	tmpEditBox = CreateEditBox()
	SetEditBoxPosition(tmpEditBox,X#,Y#)
	SetEditBoxText(tmpEditBox,default$)
	SetEditBoxTextColor( tmpEditBox,0, 0, 0 ) 
	SetEditBoxBackgroundColor( tmpEditBox, 255, 255, 255, 255 ) 
	SetEditBoxSize(tmpEditBox,(GetScreenBoundsRight()-20)/2,5)
	SetEditBoxTextSize( tmpEditBox, 40 )
	SetEditBoxFont( tmpEditBox, main_font)
	//Enter 'quit' to End
	SetEditBoxFocus(tmpEditBox,1)

	Repeat
		Sync()
	Until GetEditBoxHasFocus( tmpEditBox ) =0

	ReturnValue$ = GetEditBoxText(tmpEditBox)

	DeleteEditBox(tmpEditBox)

endfunction ReturnValue$
