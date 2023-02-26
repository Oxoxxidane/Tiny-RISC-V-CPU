`include "defines.v"

/*========================================================================

执行单元

1.执行指令
2.访问Reg File(取操作数，对rd置忙)
3.访问CSR(取操作数)
4.处理中断和异常
5.处理分支跳转(不进行写回)

=========================================================================*/

module EXU (
    input clk,
    input rst_n,
/*
    //握手
    output reg EXU_ready,
    input IDU_valid,
    output reg EXU_valid,
    input WBU_ready,
*/
    //IDU接口
    input [31:0] imm,
    input imm_h,
    input [31:0] pc,
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_in,
    input [11:0] csr_addr_in,
    input [3:0] alu_fun,
    input [3:0] type,
    input csr_rs1_choose,
    input rs2_imm_choose,

    //WBU接口
    output reg [31:0] rd_data,
    output reg [4:0] rd,
    output reg [31:0] pc_out,
    output wire [31:0] csr_data,
    output reg [11:0] csr_addr,
    output reg [2:0] w_type,

    //RegFile接口
    output wire [4:0] rs1_toRegfile,
    output wire [4:0] rs2_toRegfile,
    output wire [4:0] rd_toRegfile,
    input rs1_busy,
    input rs2_busy,
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    
    //ram接口
    output wire [31:0] addr_ram,
    output wire wre_ram,//为1写入为0读出
    output wire [31:0] data_ram,
    output wire en_ram,//ram的总时钟使能
    //csr接口
    
    input [31:0] csr_data_in,

    //IFU_jump接口
    output wire IFU_jump,
    output wire [31:0] Jump_Addr,
    output wire set_NOP

);


    
wire [31:0] alu_data1;
wire [31:0] alu_data2;

assign rs1_toRegfile = rs1_in;
assign rs2_toRegfile = rs2_in;
assign rd_toRegfile = rd_in;

assign alu_data1 = csr_rs1_choose ? csr_data_in : rs1_data;
assign alu_data2 = rs2_imm_choose ? rs2_data : imm;

assign csr_data=32'b0;


wire [31:0] alu_data2_xor;

assign alu_data2_xor = (alu_fun == 4'b1000 || alu_fun == 4'b0010) ? (~alu_data2) + 1'b1 : alu_data2;

//ALU
wire [31:0] alu_out1;
assign alu_out1 = (alu_fun[2:0] == 4'b1000 || alu_fun[2:0] == 4'b0000) ? alu_data1 + alu_data2 :
                  (alu_fun[3:0] == 4'b0010) ? alu_data1 + alu_data2 :
                  (alu_fun[3:0] == 4'b0011) ? (alu_data1 < alu_data2 ? 31'b1 : 31'b0) :
                  (alu_fun[3:0] == 4'b0100) ? alu_data1 ^ alu_data2 :
                  (alu_fun[3:0] == 4'b0110) ? alu_data1 | alu_data2 :
                  (alu_fun[3:0] == 4'b0111) ? alu_data1 & alu_data2 : alu_data1;

//桶移
always @(posedge clk) begin
    if(!rst_n) rd_data<=32'b0;
    else begin
        case(alu_fun)
            4'b0001 : rd_data <= alu_out1 << alu_data2[4:0] | 32'b0;
            4'b0010 : rd_data <= alu_out1[31] | 32'b0;
            4'b0101 : rd_data <= alu_out1 >> alu_data2[4:0] | 32'b0;
            4'b1101 : rd_data <= alu_out1 >>> alu_data2[4:0] | 32'b0;
            default : rd_data <= alu_out1;
        endcase
    end
end

//条件转移
wire is_eq; 
assign is_eq = ((rs1_data == rs2_data) ? 1'b1 : 1'b0) ^ alu_fun[0];
wire [31:0] is_ltu_pre;
assign is_ltu_pre = rs1_data + (~rs2_data);
wire is_ltu;
assign is_ltu = is_ltu_pre[31] ^ alu_fun[0];
wire is_lt;
assign is_lt = ((rs1_data < rs2_data) ? 1'b1 : 1'b0) ^ alu_fun[0];

wire B_flag = (alu_fun[2:1] == 2'b00) ? is_eq :
              (alu_fun[2:1] == 2'b10) ? is_lt : is_ltu;

assign IFU_jump = (type == 4'd5) ? 1'b1 : 
                  (type == 4'd6) ? imm_h ^ B_flag : 1'b0;
assign set_NOP = IFU_jump;
assign Jump_Addr = (type == 4'd5) ? alu_out1 : 
                   (type == 4'd6) ? (imm_h ? pc + 3'b100 : imm) : 32'b0;

//存储器
assign addr_ram = alu_out1;
assign data_ram = rs2_data;
assign wre_ram = (type == 4'd7) ? 1'b1 : 1'b0;
assign en_ram = (type == 4'd7 || type == 4'd8) ? 1'b1 : 1'b0;

//WBU接口
always @(posedge clk) begin
    if(!rst_n) rd<=5'd0;
    else rd<=rd_in;
end
always @(posedge clk) begin
    if(!rst_n) pc_out<=32'd0;
    else pc_out<=pc;
end
always @(posedge clk) begin
    if(!rst_n) csr_addr<=32'd0;
    else csr_addr<=csr_addr_in;
end
always @(posedge clk) begin
    if(!rst_n) csr_addr<=32'd0;
    else csr_addr<=csr_addr_in;
end
always @(posedge clk) begin 
    if(!rst_n) w_type<=3'b0;
    else begin
        case(type)
            4'd0 : w_type<=3'b0;
            4'd1 : w_type<=3'b0; //rd
            4'd2 : w_type<=3'b0;
            4'd3 : w_type<=3'b0;
            4'd4 : w_type<=3'd1; //PC+4
            4'd5 : w_type<=3'd1;
            4'd6 : w_type<=3'b0;
            4'd7 : w_type<=3'd2; //存储器写入
            4'd8 : w_type<=3'd3; //不写入
            4'd9 : w_type<=3'd4; //CSR类型
        endcase
    end
end

endmodule