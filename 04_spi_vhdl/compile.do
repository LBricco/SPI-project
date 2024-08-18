vlib work
echo "compiling..."
vcom clock_edge.vhd
vcom command.vhd
vcom counter.vhd
vcom mux_z.vhd
vcom PISO.vhd
vcom reg.vhd
vcom SIPO.vhd
vcom spi.vhd
vcom mem.vhd
vcom top_level.vhd
vcom tb_spi_complete.vhd

vsim -c work.tb_spi_complete

run 0ns
run 20ms

#write list counter.lst
quit -f