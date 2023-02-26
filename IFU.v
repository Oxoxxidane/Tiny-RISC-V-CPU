`include "defines.v"

/*========================================================================

ȡָ�Ԫ

1.���������ָ��ָ��Ĵ���ÿ��������4
2.ʵ��JALָ����תִ��
3.ʵ�ּ򵥾�̬��֧Ԥ��
4.֧������EXU�����̿��ƣ���JALR
5.֧���жϺ��쳣

=========================================================================*/

module IFU(
    input clk,
    input rst_n,

    output reg  [31:0] ip, //ָ��ָ��Ĵ������洢����ַ�ӿ�
    input  wire [31:0] i_in, //ָ��Ӵ洢����ָ��Ĵ����ӿ�

    //��ˮ�������źţ��൱��ʹ��
    output reg IFU_valid,
    input  IDU_ready,

    output reg [31:0] IR, //ָ��Ĵ���
    output reg [31:0] IP_next,//�����¼���ˮ��

    input jump, //��ת�ź�
    input wire [31:0] EXU_jump_ip //exu����ó�����ת��ַ
);

wire is_Jump;
wire [19:0] J_Type_Imm;
wire [11:0] B_Type_Imm;
wire B_Type_sign;
wire [11:0] Jump_Addr_Pre;
wire [30:0] Jump_Addr;
wire en;

assign is_JAL = i_in[6:0] == 7'b1101111 ? 1'b1 : 1'b0;//ֱ����ת
assign is_Branch_Pre = i_in[6:0] == 7'b1100011 ? 1'b1 : 1'b0;//Ϊ1��ʾ��Ҫ��֧Ԥ��
assign is_Jump = is_JAL | is_Branch_Pre;

assign B_Type_Imm = {i_in[31], i_in[7], i_in[30:25], i_in[11:8]};
assign J_Type_Imm = {i_in[31], i_in[19:12], i_in[20], i_in[30:21]};
assign B_Type_sign = B_Type_Imm[11];
assign Jump_Addr_Pre = B_Type_sign ? B_Type_Imm : 12'b10;
assign Jump_Addr = is_JAL ? {{11{J_Type_Imm[19]}}, J_Type_Imm} : (is_Jump ? {{19{Jump_Addr_Pre[11]}}, Jump_Addr_Pre} : 31'b0);


assign en = IFU_valid & IDU_ready; //�������ź�����ʹ���ź�

always @(posedge clk) begin 
    if(!rst_n) IR<=`NOP;
    else if(en) IR<=i_in;
    //else IR<=`NOP;
end

always @(posedge clk) begin
    if(!rst_n) IFU_valid<=1'b1;
    else IFU_valid<=1'b1; /*����Ԥ��*/
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