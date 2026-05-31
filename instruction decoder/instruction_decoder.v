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
    output reg hxhg,
    output reg swap,
    output reg push,
    output reg pop,
    output reg reg_dt_sel,
    output reg reg_wr_en,
    output reg ld_value_en,
    output reg mem_rd_en,
    output reg mem_wr_en,
    output reg [1:0] dbus_access,
    output reg [1:0] dbus_addr_sel,
    output reg [1:0] dbus_data_sel,
    output reg sp_sel,
    output reg sp_wr_en,
    output reg operand_en,
    

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

assign alu_sel = opcode;
assign alu_sop = {sop1,sop2};

reg [2:0] des_reg_dec;
reg [2:0] src_reg_dec;
reg [10:0] offset_dec;
reg [7:0] reg_value_dec;
reg [2:0] alu_value_dec;

reg halt_dec;
reg move_dec;
reg hxhg_dec;
reg swap_dec;
reg push_dec;
reg pop_dec;
reg reg_dt_sel_dec;
reg reg_wr_en_dec;
reg ld_value_en_dec;
reg mem_rd_en_dec;
reg mem_wr_en_dec;
reg [1:0] dbus_access_dec;
reg [1:0] dbus_addr_sel_dec;
reg [1:0] dbus_data_sel_dec;
reg sp_sel_dec;
reg sp_wr_en_dec;
reg operand_en_dec;

always @(*) begin 
    des_reg_dec  = 3'b0;
    src_reg_dec  = 3'b0;
    offset_dec = 11'b0;
    reg_value_dec = 8'b0;
    alu_value_dec = 3'b0;

    halt_dec = 1'b0;
    move_dec = 1'b0;
    hxhg_dec = 1'b0;
    swap_dec = 1'b0;
    push_dec = 1'b0;
    pop_dec = 1'b0;
    reg_dt_sel_dec = 1'b0;
    reg_wr_en_dec = 1'b0;
   
    mem_wr_en_dec = 1'b0;
    mem_rd_en_dec = 1'b0;
    ld_value_en_dec = 1'b0;
    dbus_access_dec = 2'b0;
    dbus_addr_sel_dec = 2'b0;
    dbus_data_sel_dec = 2'b0;
    sp_sel_dec = 1'b0;
    sp_wr_en_dec = 1'b0;
    operand_en_dec = 1'b0;

    case(opcode)
        `LDI_Value:begin
            reg_dt_sel_dec = 1'b0;
            reg_wr_en_dec = 1'b1;
            ld_value_en_dec = 1'b1;
            des_reg_dec = rd;
            reg_value_dec = reg_v;
        end
        `CALL:begin
            
        end
        `BR:begin
            
        end
        `BRR:begin
            
        end
        `BRNZ:begin
            
        end
        `BRZ:begin
            
        end
        `BRNS:begin
            
        end
        `BRS:begin
            
        end
        `BRNC:begin
            
        end
        `BRC:begin
            
        end
        `BRNV:begin
            
        end
        `BRV:begin
            
        end
        `BRNGT:begin
            
        end
        `BRGT:begin
            
        end
        `BRNLT:begin
            
        end
        `BRLT:begin
            
        end
    endcase
    case({opcode,sop2})
        `CLR_SR:begin
            
        end
        `CLR_RD:begin
            
        end
        `SET_SR:begin
            
        end
        `SET_RD:begin
            
        end
    endcase
    case (operation)
        `HALT:begin
            halt_dec = 1'b1;
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
            reg_wr_en_dec = 1'b1;
            move_dec = 1'b1;
            des_reg_dec = rd;
            src_reg_dec = rs;
        end
        `EXHG:begin
            reg_wr_en_dec = 1'b1;
            hxhg_dec = 1'b1;
            des_reg_dec = rd;
            src_reg_dec = rs;
        end
        `SWAP:begin
            reg_wr_en_dec = 1'b1;
            swap_dec = 1'b1;
            des_reg_dec = rd;
        end
        `PUSH:begin
            sp_sel_dec = 1'b1;
            sp_wr_en_dec = 1'b1;
            push_dec = 1'b1;
            dbus_access_dec = 2'b11;
            dbus_addr_sel_dec = 2'b10;
            dbus_data_sel_dec = 2'b10;
            src_reg_dec = rs;
        end
        `POP:begin
            sp_wr_en_dec = 1'b1;
            pop_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            dbus_access_dec = 2'b10;
            dbus_addr_sel_dec = 2'b11;
            dbus_data_sel_dec = 2'b00;
            des_reg_dec = rd;
        end
        `INC:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
        end
        `DEC:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
        end
        `NEC:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
        end
        `NOT:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
        end
        `SHL:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
        end
        `SHR:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
        end
        `ASL:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
        end
        `ASR:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
        end
        `ROL:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
        end
        `ROR:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
        end
        `SHL_Value:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
            alu_value_dec = rs;
        end
        `SHR_Value:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
            alu_value_dec = rs;
        end
        `ASL_Value:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
            alu_value_dec = rs;
        end
        `ASR_Value:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
            alu_value_dec = rs;
        end
        `ROL_Value:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
            alu_value_dec = rs;
        end
        `ROR_Value:begin
            operand_en_dec = 1'b1;
            reg_wr_en_dec = 1'b1;
            reg_dt_sel_dec = 1'b1;
            des_reg_dec = rd;
            alu_value_dec = rs;
        end
        `ADD:begin
            
        end
        `ADDC:begin
            
        end
        `ADDB:begin
            
        end
        `ADDBC:begin
            
        end
        `SUB:begin
            
        end
        `SUBC:begin
            
        end
        `SUBBC:begin
            
        end
        `MUL:begin
            
        end
        `MULB:begin
            
        end
        `DIV:begin
            
        end
        `DIVB:begin
            
        end
        `MOD:begin
            
        end
        `MODB:begin
            
        end
        `AND:begin
            
        end
        `OR:begin
            
        end
        `XOR:begin
            
        end
        `NOR:begin
            
        end
        `RET:begin
            
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
        hxhg <= 1'b0;
        swap <= 1'b0;
        push <= 1'b0;
        pop  <= 1'b0;
        reg_dt_sel <=1'b0;
        reg_wr_en <= 1'b0;
        ld_value_en <=1'b0;
        mem_rd_en <= 1'b0;
        mem_wr_en <= 1'b0;
        dbus_access <= 2'b0;
        dbus_addr_sel <= 2'b0;
        dbus_data_sel <= 2'b0;
        sp_sel <= 1'b0;
        sp_wr_en <= 1'b0;
        operand_en <= 1'b0;
    end
    else if(t2)begin
        des_reg <= des_reg_dec;
        src_reg <= src_reg_dec;
        offset <= offset_dec;
        reg_value <= reg_value_dec;
        alu_value <= alu_value_dec;

        halt <= halt_dec;
        move <= move_dec;
        hxhg <= hxhg_dec;
        swap <= swap_dec;
        push <= push_dec;
        pop  <= pop_dec;
        reg_dt_sel <= reg_dt_sel_dec;
        reg_wr_en <= reg_wr_en_dec;
        ld_value_en <= ld_value_en_dec;
        mem_rd_en <= mem_rd_en_dec;
        mem_wr_en <= mem_wr_en_dec;
        dbus_access <= dbus_access_dec;
        dbus_addr_sel <= dbus_addr_sel_dec;
        dbus_data_sel <= dbus_data_sel_dec;
        sp_sel <= sp_sel_dec;
        sp_wr_en <= sp_wr_en_dec;
        operand_en <= operand_en_dec;
    end
end
endmodule
