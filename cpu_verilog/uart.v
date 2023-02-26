module uart (
    input clk,
    input rst_n,
    input [7:0] data,
    output reg TX
);
    
reg [9:0] counter;

reg [6:0] div;

reg clk_115200;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) div<=6'b0;
    else if(div == 7'd117) div<=1'b0;
    else div<=div+1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) clk_115200<=1'b0;
    else if(div == 7'd117) clk_115200<=~clk_115200;
end

wire [15:0] data_send;

assign data_send = {6'b111111, data, 2'b01};

always @(posedge clk_115200 or negedge rst_n) begin
    if(!rst_n) counter<=15'b0;
    else counter<=counter+1'b1;
end

always @(posedge clk_115200 or negedge rst_n) begin
    if(!rst_n) TX<=1'b1;
    else if(counter[9:4] == 6'b0)  TX<=data_send[counter[3:0]];
    else TX<=1'b1;
end

endmodule