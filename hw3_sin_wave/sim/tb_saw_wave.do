vsim -t 1ns -lib work saw_wave

view wave
add wave *

#radix -h
radix -u

force clk 0, 1 1 -r 2
force arst 0, 1 3, 0 4
force freq_sel 0
force mode_sel 0
force wave_sel 0

# play

#run 60000000
run 500
