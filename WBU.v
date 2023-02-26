module WBU(
    input clk,
    input rst_n,

    //EXU接口
    input [31:0] rd_data,
    input [4:0] rd,
    input [31:0] pc,
    input [31:0] csr_data,
    input [11:0] csr_addr,
    input [2:0] w_type,

    //regfile接口
    output wire [4:0] rd_toRegfile,
    output wire [31:0] rd_data_toRegfile,
    
    //存储器接口
    input [31:0] data_ram

    //CSR接口
);

assign rd_toRegfile = (w_type != 3'd3) ? rd : 5'b0;
assign rd_data_toRegfile = (w_type == 3'd0) ? rd_data :
                           (w_type == 3'd1) ? pc + 3'b100 :
                           (w_type == 3'd2) ? data_ram :
                           (w_type == 3'd4) ? csr_data : 32'b0;

endmodule