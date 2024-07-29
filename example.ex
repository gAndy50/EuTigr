include tigr.e

procedure main()

	atom screen = tigrWindow(100,100,"Hello World - Use arrow keys to change background color",TIGR_AUTO)
	sequence colors = {0,0,0}
	
	while not tigrClosed(screen) and not tigrKeyDown(screen,TK_ESCAPE) do
	
		if tigrKeyDown(screen,TK_LEFT) then
			colors = {255,0,0}
			elsif tigrKeyDown(screen,TK_RIGHT) then
				colors = {0,255,0}
				elsif tigrKeyDown(screen,TK_UP) then
					colors = {0,0,255}
					elsif tigrKeyDown(screen,TK_DOWN) then
						colors = {0,0,0}
		end if
		
		tigrClear(screen,colors)
		
		tigrUpdate(screen)
		
	end while
	
	tigrFree(screen)
	
end procedure

main()
­27.1