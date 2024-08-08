# Synthesize the design with Yosys
yosys -p "synth -top top" top.v

# Simulate with Icarus Verilog
iverilog -o top_tb top_tb.v top.v
vvp top_tb

gtkwave top_tb.vcd

