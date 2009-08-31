vsim -t 1us -lib work cnt

view wave
add wave *

#radix -h
radix -u

#force sclk 0, 1 1 -r 11000
force clk 0, 1 1 -r 2
force rst 0, 1 10, 0 12
force cnt_ini 0
#force cnt_ld 
force cnt_en 0, 1 5
force cnt_end 0, 100 5


# play

run 800
