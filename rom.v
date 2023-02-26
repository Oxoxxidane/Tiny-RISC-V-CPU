module rom (
/*
    input clk,
*/
    input rst_n,
    input [6:0] addr,
    output reg [31:0] data
)/* synthesis syn_preserve = 1 */;

always @(*) begin
    if(!rst_n) data<=32'b0;
    else begin
        case (addr[6:2])
            5'h0  : data<=32'h00000013;
            5'h1  : data<=32'h00000013;
            5'h2  : data<=32'h00000013;
            5'h3  : data<=32'h00000013;
            5'h4  : data<=32'h00000013;
            5'h5  : data<=32'h00000013;
            5'h6  : data<=32'h0bb00613;
            5'h7  : data<=32'h0b500513;
            5'h8  : data<=32'h00000013;
            5'h9  : data<=32'h00000013;
            5'ha  : data<=32'h00000013;
            5'hb  : data<=32'h00000013;
            5'hc  : data<=32'h00000013;
            5'hd  : data<=32'h00000013;
            5'he  : data<=32'h00000013;
            5'hf  : data<=32'h00000013;
            5'h10 : data<=32'h00000013;
            5'h11 : data<=32'h00000013;
            5'h12 : data<=32'h00000013;
            5'h13 : data<=32'h00000013;
            5'h14 : data<=32'h00000013;
            5'h15 : data<=32'h00000013;
            5'h16 : data<=32'h00000013;
            5'h17 : data<=32'h00000013;
            5'h18 : data<=32'h00000013;
            5'h19 : data<=32'h00000013;
            5'h1a : data<=32'h00000013;
            5'h1b : data<=32'h00000013;
            5'h1c : data<=32'h00000013;
            5'h1d : data<=32'h00000013;
            5'h1e : data<=32'h00000013;
            5'h1f : data<=32'h00000013;
        endcase
    end
end
    
endmodule