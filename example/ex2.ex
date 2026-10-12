include std/ffi.e
include tigr.e

procedure main()

    -- 1. Enlarge window so (120, 110) fits, or use smaller print coordinates
    atom screen = tigrWindow(320, 240, "Hello World", TIGR_AUTO)
    
    -- 2. Include the 4th value (Alpha) in your TPixel sequences
    sequence colors = {#80, #90, #A0, #FF}
    sequence font_colors = {#FF, #FF, #00, #FF} -- Bright yellow (R=255, G=255, B=0, A=255)
    
    while not tigrClosed(screen) and not tigrKeyDown(screen, TK_ESCAPE) do
    
        tigrClear(screen, colors)
        
        -- Print inside window bounds (120, 110 fits inside 320x240)
        tigrPrint(screen, tfont, 120, 110, font_colors, "Hello World", NULL)
        
        tigrUpdate(screen)
        
    end while
    
    tigrFree(screen)
    
end procedure

main()
­28.6