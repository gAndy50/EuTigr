# EuTigr

A wrapper of the Tigr library for the openEuphoria programming language. Tigr is a small simple multimedia library that can handle windows, graphics, font and simple input. It does not handle sound or audio. 

# LICENSE
Copyright (c) <2024> <Andy P.>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Example

```euphoria
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
```
