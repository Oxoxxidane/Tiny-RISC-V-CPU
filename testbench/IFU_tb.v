`timescale 1ns/1ps
`include "defines.v"


module IFU_tb ();

reg clk;
reg rst_n;
reg [31:0] i_in;
reg IDU_ready;
reg jump;
reg [31:0] EXU_jump_ip;

wire [31:0] ip;
wire IFU_ready;
wire IR;
wire [31:0] IP_next;

initial begin
    i_in<=`NOP;
    IDU_ready<=1'b1;
    jump<=1'b0;
    rst_n<=1'b1;
    EXU_jump_ip<=32'b0;
    clk<=1'b0;
    rst_n<=1'b0;
    #2
    rst_n<=1'b1;
    #4
    i_in<=32'hffdff06f;
    #2
    i_in<=`NOP;
    #2
    i_in<=32'h00000463;
    #2
    i_in<=32'hfe000ee3;
    #2
    i_in<=`NOP;

end

always #1 clk=~clk;

IFU IFU_u1(
    .clk(clk),
    .rst_n(rst_n),

    .ip(ip), //指令指针寄存器到存储器地??接口,同时也给到下??级流水线
    .i_in(i_in), //指令从存储器到指令寄存器接口

    //流水线握手信号，相当于使??
    .IFU_valid(IFU_ready),
    .IDU_ready(IDU_ready),

    .IR(IR), //指令寄存??

    .jump(jump), //跳转信号
    .EXU_jump_ip(EXU_jump_ip) //exu计算得出的跳转地??  
);

endmodule