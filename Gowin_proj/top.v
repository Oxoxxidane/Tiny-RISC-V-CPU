module top (
    input clk,
    input rst_n,
    input [1:0] GPIO_in1,
    output wire [7:0] GPIO_out,
    output wire TX,
    output wire clk_out,
    output reg [1:0] ip_out
);

assign clk_out = clk;

wire [7:0] GPIO_in_cpu;
assign GPIO_in_cpu = {6'b0, GPIO_in1};

wire [31:0] ip;
wire [31:0] i_in;

wire [31:0] addr_ram;
wire wre_ram;
wire [31:0] data_ram;
wire en_ram;
wire [31:0] in_data_ram;

wire [7:0] GPIO_out_n;

assign GPIO_out = ~GPIO_out_n;

always @(posedge clk) ip_out[1:0]<=ip[3:2];

cpu_top cpu(
    .clk(clk),
    .rst_n(rst_n),

    //指令存储器接口
    .ip(ip),
    .i_in(i_in),

    //数据存储器接口
    .addr_ram(addr_ram),
    .wre_ram(wre_ram),
    .data_ram(data_ram),
    .en_ram(en_ram),
    .in_data_ram(in_data_ram),
    
    //GPIO
    .GPIO_out(GPIO_out_n),
    .GPIO_in(GPIO_in_cpu),

    //UART
    .uart_clk(clk),
    .TX(TX)
);

wire ce;
wire oce;
assign ce = 1'b1;
assign oce = 1'b1;

Gowin_pROM iRAM(
        .dout(i_in), //output [31:0] dout
        .clk(~clk), //input clk
        .oce(oce), //input oce
        .ce(ce), //input ce
        .reset(~rst_n), //input reset
        .ad(ip[6:2]) //input [4:0] ad
);
/*
rom rom_u(
    //.clk(~clk),
    .rst_n(rst_n),
    .addr(ip[6:0]),
    .data(i_in)
);
*/
Gowin_SP dRAM(
        .dout(in_data_ram), //output [31:0] dout
        .clk(clk), //input clk
        .oce(oce), //input oce
        .ce(en_ram), //input ce
        .reset(~rst_n), //input reset
        .wre(wre_ram), //input wre
        .ad(addr_ram[4:0]), //input [4:0] ad
        .din(data_ram) //input [31:0] din
);

endmodule