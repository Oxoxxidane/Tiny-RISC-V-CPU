`include "defines.v"

/*========================================================================

指令译码单元

1.对OP code进行译码
2.遇到非法OP抛出异常(插入NOP)
3.立即数符号扩展
4.进行与PC有关的运算

=========================================================================*/

module IDU(
    input clk,
    input rst_n,
/*
    input  IFU_valid,
    output IDU_ready,

    input  EXU_valid,
    output reg IFU_ready,
*/
    input [31:0] IR,
    input [31:0] ip,

    output reg [31:0] imm,
    output reg imm_h,//imm的符号位
    output reg [31:0] pc,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd,
    output reg [11:0] csr_addr,
    output reg [3:0] type,
    output reg [3:0] alu_fun,
    output reg csr_rs1_choose,
    output reg rs2_imm_choose
);

always @(posedge clk) begin
    if(!rst_n) pc<=32'b0;
    else pc<=ip;
end

always @(posedge clk) begin
    if(!rst_n) begin
        imm<=32'b0;
        rs1<=5'b0;
        rs2<=5'b0;
        rd<=5'b0;
        csr_addr<=12'b0;
        type<=4'b0;
        alu_fun<=4'b0;
        imm_h<=1'b0;
        csr_rs1_choose<=1'b0;
        rs2_imm_choose<=1'b0;
    end
    else begin
        case (IR[6:0])
            7'b0110111 : begin                     //LUI  U
                imm<=IR[31:12] << 4'd12;
                rs1<=5'b0;
                rs2<=5'b0;
                rd<=IR[11:7];
                csr_addr<=12'b0;
                type<=4'd2;
                alu_fun<=4'b0;
                imm_h<=1'b0;
                csr_rs1_choose<=1'b0;
                rs2_imm_choose<=1'b0;
            end                         
            7'b0010111 : begin                     //AUIPC  U
                imm<=ip + (IR[31:12] << 4'd12);
                rs1<=5'b0;
                rs2<=5'b0;
                rd<=IR[11:7];
                csr_addr<=12'b0;
                type<=4'd3;
                alu_fun<=4'b0;
                imm_h<=1'b0;
                csr_rs1_choose<=1'b0;
                rs2_imm_choose<=1'b0;
            end
            7'b1101111 : begin                     //JAL  J
                imm<=ip + ({IR[31], IR[19:12], IR[20], IR[30:21]} << 1'b1);
                rs1<=5'b0;
                rs2<=5'b0;
                rd<=IR[11:7];
                csr_addr<=12'b0;
                type<=4'd4;
                alu_fun<=4'b0;
                imm_h<=1'b0;
                csr_rs1_choose<=1'b0;
                rs2_imm_choose<=1'b0;
            end
            7'b1100111 : begin                     //JARL I 注意后面通路断开最低位 & 0xfffffffe
                imm<={{19{IR[31]}}, IR[31:20], 1'b0};
                rs1<=IR[19:15];
                rs2<=5'b0;
                rd<=IR[11:7];
                csr_addr<=12'b0;
                type<=4'd5;
                alu_fun<=4'b0;
                imm_h<=1'b0;
                csr_rs1_choose<=1'b0;
                rs2_imm_choose<=1'b0;
            end
            7'b1100011 : begin                     //BEQ BNE BLT BGE BLTU BGEU  B
                imm<=ip + ({IR[31], IR[7], IR[30:25], IR[11:8]} << 1'b1);
                rs1<=IR[19:15];
                rs2<=IR[24:20];
                rd<=5'b0;
                csr_addr<=12'b0;
                type<=4'd6;
                alu_fun<={1'b0, IR[14:12]};
                imm_h<=IR[31];
                csr_rs1_choose<=1'b0;
                rs2_imm_choose<=1'b0;
            end
            7'b0000011 : begin                     //LW  I
                imm<={{20{IR[31]}}, IR[31:20]};
                rs1<=IR[19:15];
                rs2<=5'b0;
                rd<=IR[11:7];
                csr_addr<=12'b0;
                type<=4'd7;
                alu_fun<=4'b0;
                imm_h<=1'b0;
                csr_rs1_choose<=1'b0;
                rs2_imm_choose<=1'b0;
            end
            7'b0100011 : begin                     //SW  S
                imm<={{20{IR[31]}}, IR[31:25], IR[11:7]};
                rs1<=IR[19:15];
                rs2<=IR[24:20];
                rd<=5'b0;
                csr_addr<=12'b0;
                type<=4'd8;
                alu_fun<=4'b0;
                imm_h<=1'b0;
                csr_rs1_choose<=1'b0;
                rs2_imm_choose<=1'b0;
            end
            7'b0010011 : begin                     //立即数运算  I
                imm<={{20{IR[31]}}, IR[31:20]};
                rs1<=IR[19:15];
                rs2<=5'b0;
                rd<=IR[11:7];
                csr_addr<=12'b0;
                type<=4'd0;
                alu_fun<={1'b0, IR[14:12]};//绔嬪嵆鏁扮畻鏈彸绉婚渶瑕両R[30]
                imm_h<=1'b0;
                csr_rs1_choose<=1'b0;
                rs2_imm_choose<=1'b0;
            end
            7'b0110011 : begin                     //无立即数运算  R
                imm<=32'b0;
                rs1<=IR[19:15];
                rs2<=IR[24:20];
                rd<=IR[11:7];
                csr_addr<=12'b0;
                type<=4'd1;
                alu_fun<={IR[30], IR[14:12]};
                imm_h<=1'b0;
                csr_rs1_choose<=1'b0;
                rs2_imm_choose<=1'b1;
            end
            7'b1110011 : begin                     //CSR指令  I
                imm<={27'b0, IR[19:15]};
                rs1<=IR[19:15];
                rs2<=5'b0;
                rd<=IR[11:7];
                csr_addr<=IR[31:20];
                type<=4'd9;
                alu_fun<={1'b0, IR[14:12]};
                imm_h<=1'b0;
                csr_rs1_choose<=1'b1;
                rs2_imm_choose<=1'b1;
            end
            default : begin
                imm<=32'b0;
                rs1<=5'b0;
                rs2<=5'b0;
                rd<=5'b0;
                csr_addr<=12'b0;
                type<=4'd0;
                alu_fun<=4'b0;
                imm_h<=1'b0;
                csr_rs1_choose<=1'b0;
                rs2_imm_choose<=1'b0;
            end
        endcase
    end
end

endmodule