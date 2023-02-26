`include "defines.v"

/*========================================================================

取指令单元

1.正常情况下指令指针寄存器每周期自增4
2.实现JAL指令跳转执行
3.实现简单静态分支预测
4.支持来自EXU的流程控制，如JALR
5.支持中断和异常

=========================================================================*/

module IFU(
    input clk,
    input rst_n,

    output reg  [31:0] ip, //指令指针寄存器到存储器地址接口
    input  wire [31:0] i_in, //指令从存储器到指令寄存器接口

    //流水线握手信号，相当于使能
    output reg IFU_valid,
    input  IDU_ready,

    output reg [31:0] IR, //指令寄存器
    output reg [31:0] IP_next,//给到下级流水线

    input jump, //跳转信号
    input wire [31:0] EXU_jump_ip //exu计算得出的跳转地址
);

wire is_Jump;
wire [19:0] J_Type_Imm;
wire [11:0] B_Type_Imm;
wire B_Type_sign;
wire [11:0] Jump_Addr_Pre;
wire [30:0] Jump_Addr;
wire en;

assign is_JAL = i_in[6:0] == 7'b1101111 ? 1'b1 : 1'b0;//直接跳转
assign is_Branch_Pre = i_in[6:0] == 7'b1100011 ? 1'b1 : 1'b0;//为1表示需要分支预测
assign is_Jump = is_JAL | is_Branch_Pre;

assign B_Type_Imm = {i_in[31], i_in[7], i_in[30:25], i_in[11:8]};
assign J_Type_Imm = {i_in[31], i_in[19:12], i_in[20], i_in[30:21]};
assign B_Type_sign = B_Type_Imm[11];
assign Jump_Addr_Pre = B_Type_sign ? B_Type_Imm : 12'b10;
assign Jump_Addr = is_JAL ? {{11{J_Type_Imm[19]}}, J_Type_Imm} : (is_Jump ? {{19{Jump_Addr_Pre[11]}}, Jump_Addr_Pre} : 31'b0);


assign en = IFU_valid & IDU_ready; //从握手信号生成使能信号

always @(posedge clk) begin 
    if(!rst_n) IR<=`NOP;
    else if(en) IR<=i_in;
    //else IR<=`NOP;
end

always @(posedge clk) begin
    if(!rst_n) IFU_valid<=1'b1;
    else IFU_valid<=1'b1; /*这里预留*/
end

always @(posedge clk) begin
    if(!rst_n) ip<=32'b0;
    else begin
        if(jump)
            ip<=EXU_jump_ip;
        else if(is_Jump)
            ip<=ip + {Jump_Addr, 1'b0};
        else
            ip<=ip + 3'b100;
    end
end 

always @(posedge clk) begin
    if(!rst_n) IP_next<=32'b0;
    else IP_next<=ip;
end

endmodule