--EuTigr
--Written by Andy P.
--Icy Viking Games
--Copyright (c) 2024
--Wrapper for Tigr Library
--Needs 64-bit version of Euphoria
--Tigr Version 2.0.0
--Euphoria Version 4.1.0 Beta 2 (64-bit)

include std/ffi.e
include std/machine.e
include std/os.e

public atom tigr

ifdef WINDOWS then
	tigr = open_dll("tigr.dll")
	elsifdef LINUX or FREEBSD then
	tigr = open_dll("libtigr.so")
	elsifdef OSX then
	tigr = open_dll("libtigr.dylib")
end ifdef

if tigr = 0 then
	puts(1,"Failed to load tigr library!\n")
	abort(0)
end if

--Struct for one Pixel
public constant TPixel = define_c_struct({
	C_UCHAR, --r
	C_UCHAR, --g
	C_UCHAR, --b
	C_UCHAR  --a
})

--Window flags
public constant TIGR_FIXED = 0,
				TIGR_AUTO = 1,
				TIGR_2X = 2,
				TIGR_3X = 4,
				TIGR_4X = 8,
				TIGR_RETINA = 16,
				TIGR_NOCURSOR = 32,
				TIGR_FULLSCREEN = 64
				
--Tigr Bitmap
public constant Tigr = define_c_struct({
	C_INT,C_INT, --w,h width/height (unscaled)
	C_INT,C_INT,C_INT,C_INT, --cx,cy,cw,ch clip rect
	C_POINTER, --pix TPixel pixel data
	C_POINTER, --handle os window, NULL for off-screen bitmaps
	C_INT --blitMode --target bitmap blit mode
})

--Functions

/*
--// Creates a new empty window with a given bitmap size.
--//
--// Title is UTF-8.
--//
--// In TIGR_FIXED mode, the window is made as large as possible to contain an integer-scaled
--// version of the bitmap while still fitting on the screen. Resizing the window will adapt
--// the scale in integer steps to fit the bitmap.
--//
--// In TIGR_AUTO mode, the initial window size is set to the bitmap size times the pixel
--// scale. Resizing the window will resize the bitmap using the specified scale.
--// For example, in forced 2X mode, the window will be twice as wide (and high) as the bitmap.
--//
--// Turning on TIGR_RETINA mode will request full backing resolution on OSX, meaning that
--// the effective window size might be integer scaled to a larger size. In TIGR_AUTO mode,
--// this means that the Tigr bitmap will change size if the window is moved between
--// retina and non-retina screens.
*/

public constant xtigrWindow = define_c_func(tigr,"+tigrWindow",{C_INT,C_INT,C_STRING,C_INT},C_POINTER)

public function tigrWindow(atom w,atom h,sequence title,atom flags)
	return c_func(xtigrWindow,{w,h,title,flags})
end function

--Creats empty off-screen bitmap
public constant xtigrBitmap = define_c_func(tigr,"+tigrBitmap",{C_INT,C_INT},C_POINTER)

public function tigrBitmap(atom w,atom h)
	return c_func(xtigrBitmap,{w,h})
end function

--Deletes window/bitmap
public constant xtigrFree = define_c_proc(tigr,"+tigrFree",{C_POINTER})

public procedure tigrFree(atom bmp)
	c_proc(xtigrFree,{bmp})
end procedure

--Returns non-zero if user requested to close a window
public constant xtigrClosed = define_c_func(tigr,"+tigrClosed",{C_POINTER},C_INT)

public function tigrClosed(atom bmp)
	return c_func(xtigrClosed,{bmp})
end function

--Displays a window's contents on screen and updates input
public constant xtigrUpdate = define_c_proc(tigr,"+tigrUpdate",{C_POINTER})

public procedure tigrUpdate(atom bmp)
	c_proc(xtigrUpdate,{bmp})
end procedure

--Called before doing openGL and calls before tigrUpdate
--returns non-zero if openGL is available
public constant xtigrBeginOpenGL = define_c_func(tigr,"+tigrBeginOpenGL",{C_POINTER},C_INT)

public function tigrBeginOpenGL(atom bmp)
	return c_func(xtigrBeginOpenGL,{bmp})
end function

--sets post shader for window
--replaces built-in post-FX shader
public constant xtigrSetPostShader = define_c_proc(tigr,"+tigrSetPostShader",{C_POINTER,C_STRING,C_INT})

public procedure tigrSetPostShader(atom bmp,sequence code,atom size)
	c_proc(xtigrSetPostShader,{bmp,code,size})
end procedure

/*
--// Sets post-FX properties for a window.
//
--// The built-in post-FX shader uses the following parameters:
--// p1: hblur - use bilinear filtering along the x-axis (pixels)
--// p2: vblur - use bilinear filtering along the y-axis (pixels)
--// p3: scanlines - CRT scanlines effect (0-1)
--// p4: contrast - contrast boost (1 = no change, 2 = 2X contrast, etc)
*/

public constant xtigrSetPostFX = define_c_proc(tigr,"+tigrSetPostFX",{C_POINTER,C_FLOAT,C_FLOAT,C_FLOAT,C_FLOAT})

public procedure tigrSetPostFX(atom bmp,atom p1,atom p2,atom p3,atom p4)
	c_proc(xtigrSetPostFX,{bmp,p1,p2,p3,p4})
end procedure

--Drawing

--Helper for reading pixels
--For high perfromance, just access bmp->pix directly
public constant xtigrGet = define_c_func(tigr,"+tigrGet",{C_POINTER,C_INT,C_INT},TPixel)

public function tigrGet(atom bmp,atom x,atom y)
	return c_func(xtigrGet,{bmp,x,y})
end function

--plots a pixel
--clips and blends
--for high performance just access bmp->pix directly
public constant xtigrPlot = define_c_proc(tigr,"+tigrPlot",{C_POINTER,C_INT,C_INT,TPixel})

public procedure tigrPlot(atom bmp,atom x,atom y,sequence pix)
	c_proc(xtigrPlot,{bmp,x,y,pix})
end procedure

--Clears a bitmap to a color
--no blending or clipping
public constant xtigrClear = define_c_proc(tigr,"+tigrClear",{C_POINTER,TPixel})

public procedure tigrClear(atom bmp,sequence color)
	c_proc(xtigrClear,{bmp,color})
end procedure

--Fills a rect area
--no blending or clipping
public constant xtigrFill = define_c_proc(tigr,"+tigrFill",{C_POINTER,C_INT,C_INT,C_INT,C_INT,TPixel})

public procedure tigrFill(atom bmp,atom x,atom y,atom w,atom h,sequence color)
	c_proc(xtigrFill,{bmp,x,y,w,h,color})
end procedure

--Draws a line
--start pixel is drawn, end pixel is not
--clips and blends
public constant xtigrLine = define_c_proc(tigr,"+tigrLine",{C_POINTER,C_INT,C_INT,C_INT,C_INT,TPixel})

public procedure tigrLine(atom bmp,atom x0,atom y0,atom x1,atom y1,sequence color)
	c_proc(xtigrLine,{bmp,x0,y0,x1,y1,color})
end procedure

--Draws empty rect
--drawing a 1x1 rect yields same result as calling tigrPlot
--clips and blends
public constant xtigrRect = define_c_proc(tigr,"+tigrRect",{C_POINTER,C_INT,C_INT,C_INT,C_INT,TPixel})

public procedure tigrRect(atom bmp,atom x,atom y,atom w,atom h,sequence color)
	c_proc(xtigrRect,{bmp,x,y,w,h,color})
end procedure

--Fills a rect
--fills inside of specified rect area
--calling tigrRect followed by tigrFilRect using same arguments
--cause no overdrawing
--clips and blends
public constant xtigrFillRect = define_c_proc(tigr,"+tigrFillRect",{C_POINTER,C_INT,C_INT,C_INT,C_INT,TPixel})

public procedure tigrFillRect(atom bmp,atom x,atom y,atom w,atom h,sequence color)
	c_proc(xtigrFillRect,{bmp,x,y,w,h,color})
end procedure

--Draws a circle
--drawing a zero radius circle yileds the same result as tigrPlot
--drawing a circle with radius one draws a circle three pixels wide
--clips and blends
public constant xtigrCircle = define_c_proc(tigr,"+tigrCircle",{C_POINTER,C_INT,C_INT,C_INT,TPixel})

public procedure tigrCircle(atom bmp,atom x,atom y,atom r,sequence color)
	c_proc(xtigrCircle,{bmp,x,y,r,color})
end procedure

--Fills a circle
--fills inside of specified circle
--calling tigrCircle followed by tigrFillCircle using same arguments
--caose no overdrawing
--filling a circle with zero radius has no effect
--clips and blends
public constant xtigrFillCircle = define_c_proc(tigr,"+tigrFillCircle",{C_POINTER,C_INT,C_INT,C_INT,TPixel})

public procedure tigrFillCircle(atom bmp,atom x,atom y,atom r,sequence color)
	c_proc(xtigrFillCircle,{bmp,x,y,r,color})
end procedure

--sets clip rect
--set to (0,0,-1,-1) to reset clipping to full bitmap
public constant xtigrClip = define_c_proc(tigr,"+tigrClip",{C_POINTER,C_INT,C_INT,C_INT,C_INT})

public procedure tigrClip(atom bmp,atom cx,atom cy,atom cw,atom ch)
	c_proc(xtigrClip,{bmp,cx,cy,cw,ch})
end procedure

/*
--// Copies bitmap data.
--// dx/dy = dest co-ordinates
--// sx/sy = source co-ordinates
--// w/h   = width/height
//
--// RGBAdest = RGBAsrc
--// Clips, does not blend
*/

public constant xtigrBlit = define_c_proc(tigr,"+tigrBlit",{C_POINTER,C_POINTER,C_INT,C_INT,C_INT,C_INT,C_INT,C_INT})

public procedure tigrBlit(atom dest,atom src,atom dx,atom dy,atom sx,atom sy,atom w,atom h)
	c_proc(xtigrBlit,{dest,src,dx,dy,sx,sy,w,h})
end procedure

/*
--/ Same as tigrBlit, but alpha blends the source bitmap with the
--// target using per pixel alpha and the specified global alpha.
--//
--// Ablend = Asrc * alpha
--// RGBdest = RGBsrc * Ablend + RGBdest * (1 - Ablend)
//
--// Blit mode == TIGR_KEEP_ALPHA:
--// Adest = Adest
//
--// Blit mode == TIGR_BLEND_ALPHA:
--// Adest = Asrc * Ablend + Adest * (1 - Ablend)
--// Clips and blends
*/

public constant xtigrBlitAlpha = define_c_proc(tigr,"+tigrBlitAlpha",{C_POINTER,C_POINTER,C_INT,C_INT,C_INT,C_INT,C_INT,C_INT,C_FLOAT})

public procedure tigrBlitAlpha(atom dest,atom src,atom dx,atom dy,atom sx,atom sy,atom w,atom h,atom alpha)
	c_proc(xtigrBlitAlpha,{dest,src,dx,dy,sx,sy,w,h,alpha})
end procedure

/*
--// Same as tigrBlit, but tints the source bitmap with a color
--// and alpha blends the resulting source with the destination.
//
--// Rblend = Rsrc * Rtint
--// Gblend = Gsrc * Gtint
--// Bblend = Bsrc * Btint
--// Ablend = Asrc * Atint
//
--// RGBdest = RGBblend * Ablend + RGBdest * (1 - Ablend)
//
--// Blit mode == TIGR_KEEP_ALPHA:
--// Adest = Adest
//
--// Blit mode == TIGR_BLEND_ALPHA:
--// Adest = Ablend * Ablend + Adest * (1 - Ablend)
--// Clips and blends
*/

public constant xtigrBlitTint = define_c_proc(tigr,"+tigrBlitTint",{C_POINTER,C_POINTER,C_INT,C_INT,C_INT,C_INT,C_INT,C_INT,TPixel})

public procedure tigrBlitTint(atom dest,atom src,atom dx,atom dy,atom sx,atom sy,atom w,atom h,sequence tint)
	c_proc(xtigrBlitTint,{dest,src,dx,dy,sx,sy,w,h,tint})
end procedure

public enum type TIGRBlitMode
	TIGR_KEEP_ALPHA = 0,
	TIGR_BLEND_ALPHA = 1
end type

--Set destination bitmap blend mode for blit operations
public constant xtigrBlitMode = define_c_proc(tigr,"+tigrBlitMode",{C_POINTER,C_INT})

public procedure tigrBlitMode(atom dest,atom mode)
	c_proc(xtigrBlitMode,{dest,mode})
end procedure

--For printing
public constant TigrGlyph = define_c_struct({
	C_INT, --code
	C_INT, --x
	C_INT, --y
	C_INT, --w
	C_INT  --h
})

public constant TigrFont = define_c_struct({
	C_POINTER, --bitmap 
	C_INT, --numGlyphs
	C_POINTER --glyphs
})

public enum type TCodepage
	TCP_ASCII = 0,
	TCP_1252 = 1252,
	TCP_UTF32 = 12001
end type

/*
--// Loads a font.
//
--// Codepages:
//
--//  TCP_ASCII   - Regular 7-bit ASCII
--//  TCP_1252    - Windows 1252
--//  TCP_UTF32   - Unicode subset
//
--// For ASCII and 1252, the font bitmap should contain all characters
--// for the given codepage, excluding the first 32 control codes.
//
--// For UTF32 - the font bitmap contains a subset of Unicode characters
--// and must be in the format generated by tigrFont for UTF32
*/

public constant xtigrLoadFont = define_c_func(tigr,"+tigrLoadFont",{C_POINTER,C_INT},C_POINTER)

public function tigrLoadFont(atom bitmap,atom codepage)
	return c_func(xtigrLoadFont,{bitmap,codepage})
end function

--Frees the font
public constant xtigrFreeFont = define_c_proc(tigr,"+tigrFreeFont",{C_POINTER})

public procedure tigrFreeFont(atom font)
	c_proc(xtigrFreeFont,{font})
end procedure

/*
--// Prints UTF-8 text onto a bitmap.
--// NOTE:
--//  This uses the target bitmap blit mode.
--//  See tigrBlitTint for details
*/

public constant xtigrPrint = define_c_proc(tigr,"+tigrPrint",{C_POINTER,C_POINTER,C_INT,C_INT,TPixel,C_STRING,C_POINTER})

public procedure tigrPrint(atom dest,atom font,atom x,atom y,sequence color,sequence text,object xx)
	c_proc(xtigrPrint,{dest,font,x,y,color,text,xx})
end procedure

--returns width/height of a string
public constant xtigrTextWidth = define_c_func(tigr,"+tigrTextWidth",{C_POINTER,C_STRING},C_INT),
				xtigrTextHeight = define_c_func(tigr,"+tigrTextHeight",{C_POINTER,C_STRING},C_INT)
				
public function tigrTextWidth(atom font,sequence text)
	return c_func(xtigrTextWidth,{font,text})
end function

public function tigrTextHeight(atom font,sequence text)
	return c_func(xtigrTextHeight,{font,text})
end function

--User input

--key scancodes for letters/numbers use ASCII

public enum type TKey
	TK_PAD0=128,TK_PAD1,TK_PAD2,TK_PAD3,TK_PAD4,TK_PAD5,TK_PAD6,TK_PAD7,TK_PAD8,TK_PAD9,
    TK_PADMUL,TK_PADADD,TK_PADENTER,TK_PADSUB,TK_PADDOT,TK_PADDIV,
    TK_F1,TK_F2,TK_F3,TK_F4,TK_F5,TK_F6,TK_F7,TK_F8,TK_F9,TK_F10,TK_F11,TK_F12,
    TK_BACKSPACE,TK_TAB,TK_RETURN,TK_SHIFT,TK_CONTROL,TK_ALT,TK_PAUSE,TK_CAPSLOCK,
    TK_ESCAPE,TK_SPACE,TK_PAGEUP,TK_PAGEDN,TK_END,TK_HOME,TK_LEFT,TK_UP,TK_RIGHT,TK_DOWN,
    TK_INSERT,TK_DELETE,TK_LWIN,TK_RWIN,TK_NUMLOCK,TK_SCROLL,TK_LSHIFT,TK_RSHIFT,
    TK_LCONTROL,TK_RCONTROL,TK_LALT,TK_RALT,TK_SEMICOLON,TK_EQUALS,TK_COMMA,TK_MINUS,
    TK_DOT,TK_SLASH,TK_BACKTICK,TK_LSQUARE,TK_BACKSLASH,TK_RSQUARE,TK_TICK
end type

--returns mose input for a window
public constant xtigrMouse = define_c_proc(tigr,"+tigrMouse",{C_POINTER,C_POINTER,C_POINTER,C_POINTER})

public procedure tigrMouse(atom bmp,atom x,atom y,atom buttons)
	c_proc(xtigrMouse,{bmp,x,y,buttons})
end procedure

public constant TigrTouchPoint = define_c_struct({
	C_INT, --x
	C_INT  --y
})

--reads touch input for a window
--returns number of touch points read
public constant xtigrTouch = define_c_func(tigr,"+tigrTouch",{C_POINTER,C_POINTER,C_INT},C_INT)

public function tigrTouch(atom bmp,atom points,atom maxPoints)
	return c_func(xtigrTouch,{bmp,points,maxPoints})
end function

--Reads keyboard for a window
--returns non-zero if key is pressed or held
--tigrKeyDown tests for initial press, tigrKeyHeld repeats each frame
public constant xtigrKeyDown = define_c_func(tigr,"+tigrKeyDown",{C_POINTER,C_INT},C_INT),
				xtigrKeyHeld = define_c_func(tigr,"+tigrKeyHeld",{C_POINTER,C_INT},C_INT)
				
public function tigrKeyDown(atom bmp,atom key)
	return c_func(xtigrKeyDown,{bmp,key})
end function

public function tigrKeyHeld(atom bmp,atom key)
	return c_func(xtigrKeyHeld,{bmp,key})
end function

--Reads character input for a window
--returns unicode value of last key pressed or 0 if none
public constant xtigrReadChar = define_c_func(tigr,"+tigrReadChar",{C_POINTER},C_INT)

public function tigrReadChar(atom bmp)
	return c_func(xtigrReadChar,{bmp})
end function

--Show/hide virtual keyboard
--Only for mobile devices
public constant xtigrShowKeyboard = define_c_proc(tigr,"+tigrShowKeyboard",{C_INT})

public procedure tigrShowKeyboard(atom show)
	c_proc(xtigrShowKeyboard,{show})
end procedure

--Bitmap I/O

--Loads PNG file, either from file or memory (filename is UTF-8)
--on error, returns NULL
public constant xtigrLoadImage = define_c_func(tigr,"+tigrLoadImage",{C_STRING},C_POINTER),
				xtigrLoadImageMem = define_c_func(tigr,"+tigrLoadImageMem",{C_POINTER,C_INT},C_POINTER)
				
public function tigrLoadImage(sequence fName)
	return c_func(xtigrLoadImage,{fName})
end function

public function tigrLoadImageMem(atom data,atom len)
	return c_func(xtigrLoadImageMem,{data,len})
end function

--Saves PNG file (filename is UTF-8)
--on error returns zero
public constant xtigrSaveImage = define_c_func(tigr,"+tigrSaveImage",{C_STRING,C_POINTER},C_INT)

public function tigrSaveImage(sequence fName,atom bmp)
	return c_func(xtigrSaveImage,{fName,bmp})
end function

--Helpers

--returns amount of time elapsed since tigrTime was last called
--or zero on first call
public constant xtigrTime = define_c_func(tigr,"+tigrTime",{},C_FLOAT)

public function tigrTime()
	return c_func(xtigrTime,{})
end function

--Displays error message and quits (UTF8)
--bmp can be NULL
public constant xtigrError = define_c_proc(tigr,"+tigrError",{C_POINTER,C_STRING,C_POINTER})

public procedure tigrError(atom bmp,sequence message,object x)
	c_proc(xtigrError,{bmp,message,x})
end procedure

/*
--// Reads an entire file into memory. (fileName is UTF-8)
--// Free it yourself after with 'free'.
--// On error, returns NULL and sets errno.
--// TIGR will automatically append a NUL terminator byte
--// to the end (not included in the length)
*/
public constant xtigrReadFile = define_c_func(tigr,"+tigrReadFile",{C_STRING,C_POINTER},C_POINTER)

public function tigrReadFile(sequence fName,atom len)
	return c_func(xtigrReadFile,{fName,len})
end function

--Decompressed DEFLATEd zip/zlib data into buffer
--returns non-zero on success
public constant xtigrInflate = define_c_func(tigr,"+tigrInflate",{C_POINTER,C_UINT,C_POINTER,C_UINT},C_INT)

public function tigrInflate(atom out,atom outlen,atom in,atom inlen)
	return c_func(xtigrInflate,{out,outlen,in,inlen})
end function

--Decodes a single UTF8 codepoint and returns next pointer
public constant xtigrDecodeUTF8 = define_c_func(tigr,"+tigrDecodeUTF8",{C_STRING,C_POINTER},C_STRING)

public function tigrDecodeUTF8(sequence text,atom cp)
	return c_func(xtigrDecodeUTF8,{text,cp})
end function

--Encodes a single UTF8 codepoint and returns next pointer
public constant xtigrEncodeUTF8 = define_c_func(tigr,"+tigrEncodeUTf8",{C_STRING,C_INT},C_STRING)

public function tigrEncodeUTF8(sequence text,atom cp)
	return c_func(xtigrEncodeUTF8,{text,cp})
end function
­8.40
