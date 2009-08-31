vsim -t 1ns -lib work led_sw_interval

view wave
add wave *

#radix -h
radix -u

#force sclk 0, 1 1 -r 11000
#force clk_50m 0, 1 10 -r 20
force clk_50m 0, 1 1 -r 2
force btn_south 0, 1 10, 0 12
force sw 0, b"0010" 20, b"0111" 22


# play

#run 60000000
run 50000
