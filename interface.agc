//setup scan button 

function setup_interface()
set_scan_button()
set_save_button()
set_load_button()	
set_mine_button()	
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
