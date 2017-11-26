//setup inteface and do interface related stuff
Type ScrollText
	vposition# as float
	text$ as string
	textID as integer
endtype

function setup_interface()
	createChatBox(30,95)
	//add the joysticks to the screen
set_virtual_joystick() 
set_scan_button()
set_save_button()
set_load_button()	
set_mine_button()	
ui_text()
endfunction
//setup virtual joystick
function set_virtual_joystick()
	joyStickRadius as integer=40
	AddVirtualJoystick(1,GetScreenBoundsRight() -85,GetScreenBoundsBottom() -40,joyStickRadius)
	
	LoadImage(joystickImage,"joystickthumbpad.png")
	SetVirtualJoystickImageInner( 1, joystickImage ) 
	
endfunction
// set up scan button
function set_scan_button()
	button_x as integer=15
	button_y as integer=80
	buttonSizeX as integer=20
	buttonSizeY as integer=5
	text_size as integer=10
	AddVirtualButton (1,button_x,button_y,buttonSizeX)
	SetVirtualButtonSize( 1, buttonSizeX, buttonSizeY ) 
	SetVirtualButtonText(1,"")
	//set button text
	CreateText(scan_button_text,"scan")
	SetTextDepth(scan_button_text,0)
	SetTextSize(scan_button_text,8)
	SetTextAlignment(scan_button_text,1)
	SetTextFont(scan_button_text,main_font)
	FixTextToScreen(scan_button_text,1)
	SetTextPosition(scan_button_text,button_x,button_y-(buttonSizeX/2)+((text_size/2)))
endfunction
//set up save button
function set_save_button()
	button_x as integer=15
	button_y as integer=87
	buttonSizeX as integer=20
	buttonSizeY as integer=5
	text_size as integer=10
	AddVirtualButton (2,button_x,button_y,buttonSizeX)
	SetVirtualButtonSize( 2, buttonSizeX, buttonSizeY ) 
	SetVirtualButtonText(2,"")
	//set button text
	CreateText(save_button_text,"save")
	SetTextDepth(save_button_text,0)
	SetTextSize(save_button_text,8)
	SetTextAlignment(save_button_text,1)
	SetTextFont(save_button_text,main_font)
	FixTextToScreen(save_button_text,1)
	SetTextPosition(save_button_text,button_x,button_y-(buttonSizeX/2)+((text_size/2)))
endfunction
//set up load button
function set_load_button()
	button_x as integer=15
	button_y as integer=94
	buttonSizeX as integer=20
	buttonSizeY as integer=5
	text_size as integer=10
	AddVirtualButton (3,button_x,button_y,buttonSizeX)
	SetVirtualButtonSize( 3, buttonSizeX, buttonSizeY ) 
	SetVirtualButtonText(3,"")
	//set button text
	CreateText(load_button_text,"load")
	SetTextDepth(load_button_text,0)
	SetTextSize(load_button_text,8)
	SetTextAlignment(load_button_text,1)
	SetTextFont(load_button_text,main_font)
	FixTextToScreen(load_button_text,1)
	SetTextPosition(load_button_text,button_x,button_y-(buttonSizeX/2)+((text_size/2)))
endfunction

function set_mine_button()
	button_x as integer=15
	button_y as integer=73
	buttonSizeX as integer=20
	buttonSizeY as integer=5
	text_size as integer=10
	AddVirtualButton (mine_button_text,button_x,button_y,buttonSizeX)
	SetVirtualButtonSize( mine_button_text, buttonSizeX, buttonSizeY ) 
	SetVirtualButtonText(mine_button_text,"")
	//set button text
	CreateText(mine_button_text,"mine")
	SetTextDepth(mine_button_text,0)
	SetTextSize(mine_button_text,8)
	SetTextAlignment(mine_button_text,1)
	SetTextFont(mine_button_text,main_font)
	FixTextToScreen(mine_button_text,1)
	SetTextPosition(mine_button_text,button_x,button_y-(buttonSizeX/2)+((text_size/2)))
endfunction
// setup chatbox for the first time
function createChatBox(chatPosLeft as float, chatPosBottom as float)
incoming_chat_text=createSDtxbox("Welcome to chat.",GetScreenBoundsLeft()+20,74,20)
chat_edit_text=createSDtxbox("Type chat here.",GetScreenBoundsLeft()+20,97,3)
ChatEditFocus = 0
//sync()
endfunction

//display the player's co-ordinate speed and credits under minimap
function ui_text()
// Display stuff under minimap
//co-ords
createSDtext(co_ords_text,"pos: ",GetScreenBoundsRight()-20,22)
//speedo
createSDtext(speed_text,"0.0km/s ",GetScreenBoundsRight(),24)
createSDtext(speed_title,"speed:",GetScreenBoundsRight()-20,24)
//align right
SetTextAlignment( speed_text, ARIGHT ) 
//System name
createSDtext(system_name,"System name",GetScreenBoundsRight()-20,20)
//creds display
createSDtext(red_creds,"zero red ",GetScreenBoundsRight()-18,26)
createSDtext(blue_creds,"zero blue ",GetScreenBoundsRight()-18,28)
createSDtext(green_creds,"zero green ",GetScreenBoundsRight()-18,30)
//display chat header
createSDtext(chat_header_text,"Chat: ",GetScreenBoundsLeft()+20,70)

endfunction
//reposition buttons to lower left of screen
function positionButtons()
	SetVirtualButtonPosition(1,GetScreenBoundsLeft()+10,80)
	SetTextPosition(scan_button_text,GetScreenBoundsLeft()+10,75)
	SetVirtualButtonPosition(2,GetScreenBoundsLeft()+10,87)
	SetTextPosition(save_button_text,GetScreenBoundsLeft()+10,82)
	SetVirtualButtonPosition(3,GetScreenBoundsLeft()+10,94)
	SetTextPosition(load_button_text,GetScreenBoundsLeft()+10,89)
	SetVirtualButtonPosition(4,GetScreenBoundsLeft()+10,73)
	SetTextPosition(mine_button_text,GetScreenBoundsLeft()+10,68)
endfunction
//reposition chat on resize
function positionChat()
	SetEditBoxPosition(incoming_chat_text,GetScreenBoundsLeft()+20,74)
	SetEditBoxSize(incoming_chat_text,(GetScreenBoundsRight()-40),20)
	SetTextPosition(chat_header_text,GetScreenBoundsLeft()+20,70)
	SetEditBoxPosition(chat_edit_text,GetScreenBoundsLeft()+20,95.0)
	SetEditBoxSize(chat_edit_text,GetScreenBoundsRight()-40,5)	
	//map co-ords text
	SetTextPosition(co_ords_text,GetScreenBoundsRight()-20,22)
endfunction
/**********************************************************/
/*			 creates textboxes with fixed style 					*/ 
/**********************************************************/
function createSDtxbox(default$ as string,left# as float, bottom# as float, height as integer)
	ReturnValue as integer
	tmpEditBox as integer
	tmpEditBox = CreateEditBox()

//set font and textsize
SetEditBoxFont( tmpEditBox, main_font)
SetEditBoxTextSize( tmpEditBox, 3 )
SetEditBoxText(tmpEditBox,default$)
//make sure it doesn'y move about the viewport
FixEditBoxToScreen(tmpEditBox,1)
//position it
SetEditBoxPosition(tmpEditBox,left#,bottom#)
SetEditBoxSize( tmpEditBox, (GetScreenBoundsRight()-20)/2,height )
//apply colours & style
SetEditBoxBackgroundColor(tmpEditBox, 100, 100, 100, 50)
SetEditBoxTextColor(tmpEditBox,0,0,0)
SetEditBoxBorderSize( tmpEditBox, 0.1 ) 
SetEditBoxBorderColor( tmpEditBox, 100, 100,255, 50 ) 
ReturnValue=tmpEditBox
endfunction ReturnValue

/**********************************************************/
/*			 creates text with fixed style 					*/ 
/**********************************************************/
function createSDtext(id as integer, default$ as string,left# as float, bottom# as float)
	CreateText(id,default$)
	//set font and textsize
	SetTextFont( id, main_font)
	SetTextSize( id, 2 )
	SetTextString(id,default$)
	//make sure it doesn'y move about the viewport
	FixTextToScreen(id,1)
	//position it
	SetTextPosition(id,left#,bottom#)
	//apply colours & style
	SetTextColor(id,255,255,255,255)
endfunction 

//update award display to show earnings
function recieveEarnings(earned as integer)
	//if the scan was more than 50% successful
	if earned>15
		discoverNumber(gamestate.playerShip.position)
		//TODO show award text and animate
		newScrollingText("You Earned "+str(earned)+ " blue crystals!")
		//update local blue credits variable
		gamestate.session.blueCredits=gamestate.session.blueCredits+earned	
		//update UI from local variable
		SetTextString(blue_creds,str(gamestate.session.blueCredits))
		PlaySound(scan_success)
		gamestate.session.bluepayout=earned
	
	//scan was not good enough
	else
		PlaySound(scan_fail)
	endif
endfunction

function updateScrollText()
	index as integer
	alpha as integer
	//for all entries in the payout array
	for index=0 to textScrollArray.length
		//increment start vector by speed to move one step closer to endpoint 
	textScrollArray[index].vPosition# =textScrollArray[index].vPosition#-0.5
		SetTextPosition(textScrollArray[index].textID,50,textScrollArray[index].vPosition#)
		//decrease alpha of text at end
		if textScrollArray[index].vPosition#<200
					alpha=textScrollArray[index].vPosition#*12.75
		endif
		if textScrollArray[index].vPosition#>30
					alpha=(637)-(textScrollArray[index].vPosition#*12.75)
		endif
		//set text alpha
		SetTextColorAlpha (textScrollArray[index].textID,alpha)
	
		//if the particle has reached the endpoint, delete it
		if (textScrollArray[index].vPosition#< 0)
			deleteText(textScrollArray[index].textID)
			textScrollArray.remove(index)
		endif
	next
endfunction

//creates new scrolling text object and stores in scrollingtext array
function newScrollingText(text$ as string)
	//create 2 text objects, text and shadow.
	TextID as integer
	TextID2 as integer
	MyScrollingText as ScrollText
	MyScrollingText2 as ScrollText
	MyScrollingText.vPosition#=40
	MyScrollingText2.vPosition#=40.5
	//create shadow first so it is behind
	TextID2=CreateText(text$) 
	TextID=CreateText(text$) 
	//apply colours & style to main text
	SetTextColor(TextID,255,255,255,0)
	SetTextX(TextID,50)
	SetTextY(TextID,MyScrollingText.vPosition#)
	FixTextToScreen(TextID,1)
	SetTextAlignment(TextID, 1 ) 
	//set font and textsize
	SetTextFont( TextID, main_font)
	SetTextSize( TextID, 5 )
	//apply colours & style to shadow
	SetTextColor(TextID2,1,1,1,0)
	SetTextX(TextID2,5.5)
	SetTextY(TextID2,MyScrollingText2.vPosition#)
	FixTextToScreen(TextID2,1)
	SetTextAlignment(TextID2, 1 ) 
	//set font and textsize
	SetTextFont( TextID2, main_font)
	SetTextSize( TextID2, 5 )

	MyScrollingText.textID=TextID
	MyScrollingText2.textID=TextID2
	textScrollArray.insert(MyScrollingText2)
	textScrollArray.insert(MyScrollingText)
	sync()
endfunction
