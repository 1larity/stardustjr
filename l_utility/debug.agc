/********************************************************/
/*             		 Debug Logging		                */
/*Function:-											*/
/*log debug info to file								*/
/*				copyright Richard Beech 2017			*/
/********************************************************/

/********************************************************/
/*    write the provided text to the debug file         */
/********************************************************/
function writeDebug(text$)
	debugFile as integer
    // open in append mode
    debugFile=openToWrite("..\debugLog.agc",1)
 
    // output the string
    writeLine(debugFile,GetCurrentDate() + " " +GetCurrentTime() +" "+ text$)
 
    // close it to force output
    closefile(debugFile)
endfunction


/*******************************************************************/
/* Initialise debug file, write gamename and platform to blank file*/
/*******************************************************************/
 
function initDebug(game AS string)
    debugFile as integer
    // open and clear the file
    debugFile=openToWrite("..\debugLog.agc",0)
 
    // close it to force output
    closefile(debugFile)
 
    // add some info
    writeDebug("================================================================================")
    writeDebug("Game: "+game)
    writeDebug("Platform: "+GetDeviceName())
    writeDebug("================================================================================")
endfunction
