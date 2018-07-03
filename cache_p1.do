vsim -gui -novopt -t ns work.cache_tb

add wave -position insertpoint  sim:/cache_tb/cache/clk
add wave -position insertpoint  sim:/cache_tb/cache/reset
add wave -position insertpoint  sim:/cache_tb/pr_addr
add wave -position insertpoint  sim:/cache_tb/cache/pr_rd
add wave -position insertpoint  sim:/cache_tb/cache/pr_din
add wave -position insertpoint  sim:/cache_tb/cache/pr_wr
add wave -position insertpoint  sim:/cache_tb/cache/pr_dout
add wave -position insertpoint  sim:/cache_tb/cache/cvalid
add wave -position insertpoint  sim:/cache_tb/cache/req
add wave -position insertpoint  sim:/cache_tb/cache/hit
add wave -position insertpoint  sim:/cache_tb/cache/tag
add wave -position insertpoint  sim:/cache_tb/cache/data
add wave -position insertpoint  sim:/cache_tb/cache/valid
add wave -position insertpoint  sim:/cache_tb/cache/dirty
add wave -radix ASCII -position insertpoint  sim:/cache_tb/state_string
add wave -position insertpoint  sim:/cache_tb/mem_rd
add wave -position insertpoint  sim:/cache_tb/mem_dout
add wave -position insertpoint  sim:/cache_tb/mem_wr
add wave -position insertpoint  sim:/cache_tb/mem_din
add wave -position insertpoint  sim:/cache_tb/mem_addr
add wave -position insertpoint  sim:/cache_tb/mem_done


TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 150
configure wave -valuecolwidth 57
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update

run 350 ns
wave zoom full