/****************************************************************/
/*                  SETUP VIDEO DEFAULTS 						*/
/****************************************************************/
function setupVideo()
	// set window properties
	SetWindowTitle( "StardustJR" )		// set the apps title 
	SetWindowSize( 1000, 1000, 0 )		//set window size (on PC)
	SetWindowAllowResize( 1 )			// allow the user to resize the window

	// set display properties
	SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
	SetSyncRate( 30, 0 ) 				// 30fps instead of 60 to save battery
	SetScissor( 0,0,0,0 )				// use the maximum available screen space, no black borders
	UseNewDefaultFonts( 1 ) 			// since version 2.0.22 we can use nicer default fonts
	SetDisplayAspect(1.0) 				// set window apect to prevent scaling issues
	SetPrintSize( 2 )					//set deafult (debug) text to small
endfunction
