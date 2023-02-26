//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.09 Education
//Part Number: GW1NSR-LV4CQN48PC6/I5
//Device: GW1NSR-4C
//Created Time: Tue Jan 10 20:40:21 2023

module Gowin_pROM (dout, clk, oce, ce, reset, ad);

output [31:0] dout;
input clk;
input oce;
input ce;
input reset;
input [4:0] ad;

wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO(dout[31:0]),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,gw_gnd,gw_gnd,gw_gnd,ad[4:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_0.READ_MODE = 1'b0;
defparam prom_inst_0.BIT_WIDTH = 32;
defparam prom_inst_0.RESET_MODE = "SYNC";
defparam prom_inst_0.INIT_RAM_00 = 256'h001101130010011368008093009890B700800313000002930010051300000013;
defparam prom_inst_0.INIT_RAM_01 = 256'h006020670AA0061300B18663FC628AE3001282930010019300151513FE209EE3;
defparam prom_inst_0.INIT_RAM_02 = 256'h000000130000001300000013000000130000001300000013006020670BB00613;
defparam prom_inst_0.INIT_RAM_03 = 256'h0000001300000013000000130000001300000013000000130000001300000013;

endmodule //Gowin_pROM
