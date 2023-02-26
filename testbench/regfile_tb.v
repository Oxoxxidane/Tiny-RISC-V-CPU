`timescale 1ns/1ps

module regfile_tb ();
    
reg clk;
reg rst_n;
reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;
reg [31:0] i_in;
reg [4:0] rd_exu;

initial begin
    clk<=1'b0;
    rs1<=5'b0;
    rs2<=5'b0;
    rd_exu<=5'b0;
    rd<=5'b0;
    rst_n<=1'b0;
    #2
    rst_n<=1'b1;
    #2
    rd<=5'd2;
    i_in<=32'hf0f0feec;
    #2
    rd<=5'd0;
    rd_exu<=5'd2;
    i_in<=32'hfff00000;
    rs1<=5'd1;
    rs2<=5'd2;
    #2
    rd<=5'd3;
    i_in<=32'h0ecccccc;
    rd_exu<=5'd3;
    rs1<=5'd2;
    rs2<=5'd3;
    #2
    rd_exu<=5'b0;
    rs1<=5'b0;
    rs2<=5'b0;
    rd<=5'd2;
    #2
    rd<=5'b0;
end

always #1 clk=~clk;

regfile refile_u1(
    .clk(clk),
    .rst_n(rst_n),
    
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .rd_exu(rd_exu),
    .in_data(i_in)
);

endmodule