REM build batch does various things to build client for distrobution, copy in library files
REM ftp php files

REM copy in libs from test/dev
REM copy station lib in from test
copy ..\test\spacestation.agc ..\stardustjr\l_simulation

REM copy files to build folder
REM Images
copy ..\stardustjr\media\*.png "\stardust build\media\"
REM wav sound files
copy ..\stardustjr\media\*.wav "\stardust build\media\"
REM ogg music files
copy ..\stardustjr\media\*.ogg "\stardust build\media\"
REM fonts
copy ..\stardustjr\media\*.ttf "\stardust build\media\"
REM atlas files
copy ..\stardustjr\media\*.txt "\stardust build\media\"
REM bytecode
copy ..\stardustjr\media\bytecode.byc "\stardust build\media\"


REM Next line NOT needed if WinSCP folder was added to PATH 
REM CD "C:\Program Files (x86)\WinSCP" 
"C:\Program Files (x86)\WinSCP\Winscp.com" /script=uploadscript.txt


REM pause

