module regfile (
    input clk,
    input rst_n,
    
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd_exu,
    input [4:0] rd,
    input [31:0] in_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    output wire rs1_busy,
    output wire rs2_busy,

    output wire [7:0] GPIO_out,
    input [7:0] GPIO_in,
    output wire [7:0] uart
);
    
//rd_exu置忙位，写入数据清除忙位

reg [31:0] regs [31:0];
reg [31:0] regs_busy;

wire [31:0] busy_rdset0;
wire [31:0] busy_rdset1;

assign rs1_data = (rd != rs1 || rs1 == 5'b0) ? regs[rs1] : in_data;
assign rs2_data = (rd != rs2 || rs2 == 5'b0) ? regs[rs2] : in_data;//旁路
assign rs1_busy = rd != rs1 ? regs_busy[rs1] : 1'b0;
assign rs2_busy = rd != rs2 ? regs_busy[rs2] : 1'b0;

assign GPIO_out = regs[10][7:0];
assign uart = regs[12][7:0];

always @(posedge clk) begin
    if(rd != 5'b0) begin
        if (rd == 5'd11) begin
            regs[0]<=32'b0;
            regs[11]<=in_data | GPIO_in;
        end
        else begin
            regs[0]<=32'b0;
            regs[11]<=GPIO_in | 32'b0;
            regs[rd]<=in_data;
        end
    end
    else 
        regs[0]<=32'b0;
end

assign busy_rdset0 = ~(32'b1 << rd);
assign busy_rdset1 = 32'b1 << rd_exu;

always @(posedge clk) begin
    if(!rst_n) regs_busy<=32'b0;
    else
        regs_busy <= (regs_busy & busy_rdset0) | busy_rdset1 & 32'hfffffffe;
end

endmodule