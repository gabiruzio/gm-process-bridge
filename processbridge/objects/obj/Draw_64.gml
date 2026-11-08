draw_set_alpha(1)
draw_set_colour(c_white)
draw_text(40, 40, $"main: {shm_peek(SHM_MAIN, 0, buffer_u64)}")
draw_text(40, 80, $"core: {shm_peek(SHM_CORE, 0, buffer_string)}")
 

