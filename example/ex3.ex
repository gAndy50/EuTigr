include std/ffi.e
include tigr.e
include openGL.e

atom win = tigrWindow(320,240,"Win",TIGR_AUTO)
atom win2 = tigrWindow(320,240,"Win 2",TIGR_AUTO)

sequence win_colors = {#80,#90,#A0,#FF}

sequence font_colors = {#FF,#FF,#00,#FF}

while win or win2 do	
	if win then
		tigrClear(win,win_colors)
		tigrPrint(win,tfont,120,110,font_colors,"Hello World",NULL)
		tigrUpdate(win)
	
		if tigrClosed(win) or tigrKeyDown(win,TK_ESCAPE) then
			tigrFree(win)
			win = NULL
		end if
	end if
	
	if win2 then
		if tigrBeginOpenGL(win2) then
			glClearColor(1,0,1,0)
			glClear(GL_COLOR_BUFFER_BIT)
		end if
		
		tigrClear(win2,{0,0,0,0})
		tigrPrint(win2,tfont,120,110,font_colors,"Hello World 2",NULL)
		tigrUpdate(win2)
		
		if tigrClosed(win) or tigrKeyDown(win2,TK_ESCAPE) then
			tigrFree(win2)
			win2 = NULL
		end if
	end if
end while
­28.1