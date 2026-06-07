module top (
input wire clock,
input wire resetb,

input  wire [15:0] pbus_in_data,
output wire [15:0] p_addr,
output wire prdb_pin,
output wire pcsb_pin,

output wire [15:0] d_addr,
output wire [15:0] dmem_wdata,
output wire drdb_pin,
output wire dwrb_pin,
output wire dcsb_pin
);
//state control
wire t1,t2,t3,t4,t5;

//program counter
wire next_pc;

//stack pointer
wire sp_out;

//status register
wire cf,zf,nf,vf,sf,hf,ltf,gtf;
wire cf_out;

//instruction register
wire [15:0] instruction_out;
wire wr_en;

//instruction decoder
wire [2:0] des_reg;
wire [2:0] src_reg;
wire [10:0] offset;
wire [7:0] reg_value;
wire [2:0] alu_value;

wire halt;
wire move;
wire hxhg;
wire swap;
wire push;
wire pop;
wire reg_dt_sel;
wire reg_wr_en;
wire ld_value_en;
wire mem_rd_en;
wire mem_wr_en;
wire [1:0] dbus_access;
wire [1:0] dbus_addr_sel;
wire [1:0] dbus_data_sel; 
wire sp_sel;
wire sp_wr_en; 
wire operand_en;
wire sreg_wr_en;
wire sr_bit_en;
wire sr_bit_sel;
wire sr_bit_idx;
wire exe_32;
wire pc_wr_en;
wire [1:0] pc_sel;
wire clr;
wire set;

wire [4:0] alu_sel;
wire [4:0] alu_sop;

//register
wire [15:0] r_operand;
wire [15:0] l_operand;

wire [15:0] rd_data;
wire [15:0] rs_data;

//alu
wire [15:0] alu_result0;
wire [15:0] alu_result1;

wire alu_zf, alu_cf, alu_nf, alu_vf, alu_gtf, alu_ltf;

state_control u_state_control (
    .clock(clock),
    .resetb(resetb)
);

program_counter u_program_counter (
    .clock(clock),
    .resetb(resetb)
);

stack_pointer u_stack_pointer (
    .clock(clock),
    .resetb(resetb)
);

status_register u_status_register (
    .clock(clock)
);

instruction_register u_instruction_register (
    .clock(clock)
);

instruction_decoder u_instruction_decoder (
    .clock(clock)
);

register u_register (
    .clock(clock)
);

alu u_alu (
       
);

program_bus u_program_bus (
    .clock(clock)
);

data_bus u_data_bus (
    .clock(clock)
);

endmodule