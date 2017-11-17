//setup scan button 

function setup_interface()
	createChatBox()
	//add the joysticks to the screen
set_virtual_joystick() 
set_scan_button()
set_save_button()
set_load_button()	
set_mine_button()	

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
function createChatBox()
// Display the ChatBox with incoming messages
 CreateText(incoming_chat_text,"Welcome to the Chat !")
SetTextMaxWidth( incoming_chat_text, 50.0 )
//SetTextScissor
FixTextToScreen(incoming_chat_text,1)
SetTextPosition(incoming_chat_text,30,70)
SetTextSize(incoming_chat_text,5)
//SetTextColor(ChatBoxMessage,0,0,0,255)

// Display the Header Chat Input textbox
CreateText(chat_header_text,"Chat : ")
FixTextToScreen(chat_header_text,1)
SetTextPosition(chat_header_text,30,65)
SetTextSize(chat_header_text,5)
//SetTextColor(LabelMessage,255,255,255,255)
SetTextVisible(chat_header_text,1)

CreateEditBox(chat_edit_text)
SetEditBoxSize(chat_edit_text,50,5)
SetEditBoxTextSize( chat_edit_text, 5 )
FixEditBoxToScreen(chat_edit_text,1)
SetEditBoxPosition(chat_edit_text,30,95.0)
SetEditBoxFocus(chat_edit_text,0)
SetEditBoxVisible(chat_edit_text,1)
ChatEditFocus = 0
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
	SetTextPosition(incoming_chat_text,GetScreenBoundsLeft()+25,70)
	SetTextPosition(chat_header_text,GetScreenBoundsLeft()+25,65)
	SetEditBoxPosition(chat_edit_text,GetScreenBoundsLeft()+25,95.0)
	SetEditBoxSize(chat_edit_text,(GetScreenBoundsRight()-20)/1.25,5)
	SetTextMaxWidth( incoming_chat_text, (GetScreenBoundsRight()-20)/1.25 )
	SetVirtualButtonPosition(1,GetScreenBoundsLeft()+10,80)
	SetVirtualButtonPosition(2,GetScreenBoundsLeft()+10,87)
	SetVirtualButtonPosition(3,GetScreenBoundsLeft()+10,94)
	SetVirtualButtonPosition(4,GetScreenBoundsLeft()+10,73)
endfunction
