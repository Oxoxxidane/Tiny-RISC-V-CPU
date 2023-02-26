module cpu_top (
    input clk,
    input rst_n,

    //指令存储器接口
    output wire [31:0] ip,
    input [31:0] i_in,

    //数据存储器接口
    output wire [31:0] addr_ram  ,
    output wire wre_ram          ,
    output wire [31:0] data_ram  ,
    output wire en_ram           ,
    input [31:0] in_data_ram     ,
    
    //GPIO
    output wire [7:0] GPIO_out,
    input [7:0] GPIO_in,

    //UART
    input uart_clk,
    output wire TX
)/* synthesis syn_preserve = 1 */;

wire [31:0] IR_IFU_IDU;
wire [31:0] IP_next;
wire jump;
wire [31:0] EXU_jump_ip;
wire IFU_valid;

IFU IFU_u(
    .clk(clk),
    .rst_n(rst_n),

    .ip(ip), //指令指针寄存器到存储器地址接口
    .i_in(i_in), //指令从存储器到指令寄存器接口

    //流水线握手信号，相当于使能
    .IDU_ready(1'b1),
    .IFU_valid(IFU_valid),

    .IR(IR_IFU_IDU), //指令寄存器
    .IP_next(IP_next),//给到下级流水线

    .jump(jump), //跳转信号
    .EXU_jump_ip(EXU_jump_ip & 32'hfffffffe) //exu计算得出的跳转地址
);

wire [31:0] imm;        
wire imm_h;//imm的符号位    
wire [31:0] pc;         
wire [4:0] rs1;         
wire [4:0] rs2;         
wire [4:0] rd_IDU;   
wire [11:0] csr_addr_IDU;   
wire [3:0] type;     
wire [3:0] alu_fun;    
wire csr_rs1_choose;    
wire rs2_imm_choose; 

wire set_NOP;
reg set_nop_next;
wire IDU_rst;

always @(posedge clk) begin
    if(!rst_n) set_nop_next<=1'b1;
    else set_nop_next<=~set_NOP;//延迟一个周期
end

assign IDU_rst = rst_n & set_nop_next & (~set_NOP);

IDU IDU_u(
    .clk(clk),
    .rst_n(IDU_rst),

    .IR(IR_IFU_IDU),
    .ip(IP_next),

    .imm                  (imm           ) ,
    .imm_h                (imm_h         ) ,//imm的符号位
    .pc                   (pc            ) ,
    .rs1                  (rs1           ) ,
    .rs2                  (rs2           ) ,
    .rd                   (rd_IDU        ) ,
    .csr_addr             (csr_addr_IDU  ) ,
    .type                 (type          ) ,
    .alu_fun              (alu_fun       ) ,
    .csr_rs1_choose       (csr_rs1_choose) ,
    .rs2_imm_choose       (rs2_imm_choose)
);

wire [4:0] rs1_reg;          
wire [4:0] rs2_reg;
wire [4:0] rd_exu;         
wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire rs1_busy;
wire rs2_busy; 
  
wire [31:0] rd_data; 
wire [4:0] rd_WBU;      
wire [31:0] pc_out;  
wire [31:0] csr_data;
wire [11:0] csr_addr;
wire [2:0] w_type;   

EXU EXU_u(
    .clk(clk),
    .rst_n(rst_n),

    //IDU接口
    .imm                  (imm           ) ,
    .imm_h                (imm_h         ) ,
    .pc                   (pc            ) ,
    .rs1_in               (rs1           ) ,
    .rs2_in               (rs2           ) ,
    .rd_in                (rd_IDU        ) ,
    .csr_addr_in          (csr_addr_IDU  ) ,
    .alu_fun              (alu_fun       ) ,
    .type                 (type          ) ,
    .csr_rs1_choose       (csr_rs1_choose) ,
    .rs2_imm_choose       (rs2_imm_choose) ,

    //WBU接口
    .rd_data  (rd_data ),
    .rd       (rd_WBU  ),
    .pc_out   (pc_out  ),
    .csr_data (csr_data),
    .csr_addr (csr_addr),
    .w_type   (w_type  ),

    //RegFile接口
    .rs1_toRegfile(rs1_reg),
    .rs2_toRegfile(rs2_reg),
    .rd_toRegfile(rd_exu),
    .rs1_busy(rs1_busy),
    .rs2_busy(rs2_busy),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    
    //ram接口
    .addr_ram  (addr_ram),
    .wre_ram   (wre_ram ),//为1写入为0读出
    .data_ram  (data_ram),
    .en_ram    (en_ram  ),//ram的总时钟使能
    //csr接口
    
    .csr_data_in(32'b0),

    //IFU_jump接口
    .IFU_jump(jump),
    .Jump_Addr(EXU_jump_ip),
    .set_NOP(set_NOP)

);

wire [4:0] rd;
wire [31:0] in_data;

wire [7:0] uart;

regfile regfile_u(
    .clk(clk),
    .rst_n(rst_n),
    
    .rs1(rs1_reg),
    .rs2(rs2_reg),
    .rd_exu(rd_exu),
    .rd(rd),
    .in_data(in_data),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .rs1_busy(rs1_busy),
    .rs2_busy(rs2_busy),

    .GPIO_out(GPIO_out),
    .GPIO_in(GPIO_in),
    .uart(uart)
);

uart uart_u(
    .clk(uart_clk),
    .rst_n(rst_n),
    .data(uart),
    .TX(TX)
);

WBU WBU_u(
    .clk(clk),
    .rst_n(rst_n),

    //EXU接口
    .rd_data (rd_data ),
    .rd      (rd_WBU  ),
    .pc      (pc_out  ),
    .csr_data(csr_data),
    .csr_addr(csr_addr),
    .w_type  (w_type  ),

    //regfile接口
    .rd_toRegfile(rd),
    .rd_data_toRegfile(in_data),
    
    //存储器接口
    .data_ram(in_data_ram)
);

endmodule