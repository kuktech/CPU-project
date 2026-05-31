`include "1.defines/define.vh"

module instruction_decoder (
    input wire clock,
    input wire resetb,

    input wire t2,

    input [15:0] instruction,
    output reg [2:0] des_reg,
    output reg [2:0] src_reg,
    output reg [10:0] offset,
    output reg [7:0] reg_value,
    output reg [2:0] alu_value,

    output reg halt,
    output reg move,
    output reg reg_dt_sel,
    output reg reg_wr_en,
    output reg ld_value_en,
    output reg mem_rd_en,
    output reg mem_wr_en,
    output reg [1:0] dbus_access,
    output reg [1:0] dbus_addr_sel,
    output reg [1:0] dbus_data_sel,


    output wire [4:0] alu_sel,
    output wire [4:0] alu_sop

);
wire [2:0] rd = instruction[10:8];
wire [2:0] rs = instruction[7:5];
wire [10:0] os = instruction[10:0];
wire [7:0] reg_v = instruction[7:0];
wire [2:0] alu_v = instruction[7:5];

wire [4:0] opcode = instruction[15:11];
wire [2:0] sop1 = instruction[4:2];
wire [1:0] sop2 = instruction[1:0];

wire [9:0] operation = {opcode,sop1,sop2};

assign alu_sel = instruction[15:11];
assign alu_sop = instruction[4:0];

reg [2:0] des_reg_dec;
reg [2:0] src_reg_dec;
reg [10:0] offset_dec;
reg [7:0] reg_value_dec;
reg [2:0] alu_value_dec;

reg halt_dec;
reg move_dec;
reg reg_dt_sel_dec;
reg reg_wr_en_dec;
reg ld_value_en_dec;
reg mem_rd_en_dec;
reg mem_wr_en_dec;
reg [1:0] dbus_access_dec;
reg [1:0] dbus_addr_sel_dec;
reg [1:0] dbus_data_sel_dec;


always @(*) begin 
    des_reg_dec  = 3'b0;
    src_reg_dec  = 3'b0;
    offset_dec = 11'b0;
    reg_value_dec = 8'b0;
    alu_value_dec = 3'b0;

    halt_dec = 1'b0;
    move_dec = 1'b0;
    reg_dt_sel_dec = 1'b0;
    reg_wr_en_dec = 1'b0;
    mem_rd_en_dec = 1'b0;
    mem_wr_en_dec = 1'b0;
    ld_value_en_dec = 1'b0;
    dbus_access_dec = 2'b0;
    dbus_addr_sel_dec = 2'b0;
    dbus_data_sel_dec = 2'b0;

    case (operation)
        `HALT:begin
            halt_dec = 1'b1;
        end
        `LDI_Value:begin
            reg_dt_sel_dec = 1'b0;
            reg_wr_en_dec = 1'b1;
            ld_value_en_dec = 1'b1;
            des_reg_dec = rd;
            reg_value_dec = reg_v;
        end
        `LDI:begin
            reg_wr_en_dec = 1'b1;
            mem_rd_en_dec = 1'b1;
            dbus_access_dec = 2'b10;
            dbus_addr_sel_dec = 2'b00;
            dbus_data_sel_dec = 2'b00;
            des_reg_dec = rd;
            src_reg_dec = rs;
        end
        `STI:begin
            mem_wr_en_dec = 1'b1;
            dbus_access_dec = 2'b11;
            dbus_addr_sel_dec = 2'b01;
            dbus_data_sel_dec = 2'b01;
            des_reg_dec = rd;
            src_reg_dec = rs;
        end
        `MV:begin
            
        end
    
        default: begin
        end
    endcase
end

always @(posedge clock or negedge resetb) begin
    if(!resetb)begin
        des_reg <= 3'b0;
        src_reg <=3'b0;
        offset <= 11'b0;
        reg_value <= 8'b0;
        alu_value <= 3'b0;

        halt <= 1'b0;
        move <= 1'b0;
        reg_dt_sel <=1'b0;
        reg_wr_en <= 1'b0;
        ld_value_en <=1'b0;
        mem_rd_en <= 1'b0;
        mem_wr_en <= 1'b0;
        dbus_access <= 2'b0;
        dbus_addr_sel <= 2'b0;
        dbus_data_sel <= 2'b0;
    end
    else if(t2)begin
        des_reg <= des_reg_dec;
        src_reg <= src_reg_dec;
        offset <= offset_dec;
        reg_value <= reg_value_dec;
        alu_value <= alu_value_dec;

        halt <= halt_dec;
        move <= move_dec;
        reg_dt_sel <= reg_dt_sel_dec;
        reg_wr_en <= reg_wr_en_dec;
        ld_value_en <= ld_value_en_dec;
        mem_rd_en <= mem_rd_en_dec;
        mem_wr_en <= mem_wr_en_dec;
        dbus_access <= dbus_access_dec;
        dbus_addr_sel <= dbus_addr_sel_dec;
        dbus_data_sel <= dbus_data_sel_dec;
    end
end
endmodule
