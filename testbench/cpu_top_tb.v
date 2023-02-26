`timescale 1ns/1ps
`include "defines.v"

module cpu_top_tb();

reg clk;
reg rst_n;
wire [31:0] i_in;
reg [31:0] in_data_ram;
reg [7:0] GPIO_in;

wire [31:0] ip;
wire [31:0] addr_ram;
wire wre_ram;
wire [31:0] data_ram;
wire en_ram;
wire [7:0] GPIO_out;
wire TX;

initial begin
    clk<=1'b0;
    rst_n<=1'b0;
    GPIO_in<=8'b00000000;
    in_data_ram<=32'hfffffffe;
    #2
    rst_n<=1'b1;
    /*
    i_in<=`NOP;
    #2
    i_in<=32'h0aa00613;
    #2
    i_in<=32'h0b500513;
    #2
    i_in<=`NOP;
    
    #2
    i_in<=32'h00f0f0b7;
    #2
    i_in<=32'h00f00117;
    #2
    i_in<=32'h00708093;
    #2
    i_in<=32'h0020c1b3;
    #2
    i_in<=32'h0aa00613;
    #2
    i_in<=32'h0071a267;
    #2
    i_in<=32'h0aa00693;
    #2
    i_in<=32'h0aa00693;
    #2
    i_in<=32'h00110863;
    #2
    i_in<=32'hfe110ce3;
    #2
    i_in<=`NOP;
    #2
    i_in<=`NOP;
    #2
    i_in<=32'h00116763;
    #2
    i_in<=`NOP;
    */
end

always #1 clk=~clk;

cpu_top cpu1(
    .clk(clk),
    .rst_n(rst_n),

    //指令存储器接口
    .ip(ip),
    .i_in(i_in),

    //数据存储器接口
    .addr_ram  (addr_ram),
    .wre_ram   (wre_ram),
    .data_ram  (data_ram),
    .en_ram    (en_ram),
    .in_data_ram(in_data_ram),
    
    //GPIO
    .GPIO_out(GPIO_out),
    .GPIO_in(GPIO_in),

    //UART
    .uart_clk(clk),
    .TX(TX)
);

rom rom_u(
    .clk(~clk),
    .rst_n(rst_n),
    .addr(ip[6:2]),
    .data(i_in)
);


endmodule