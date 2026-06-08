module top (
input wire clock,
input wire resetb,

input wire [15:0] program_data,

output wire [15:0] pbus_in_address,
output reg prdb_pin,
output reg pcsb_pin,

output reg [15:0] mbr,
output reg [15:0] mar,
output reg drdb_pin,
output reg dwrb_pin,
output reg dcsb_pin
);
//state control
wire t1,t2,t3,t4,t5;

//program counter
wire [15:0] next_pc;

//stack pointer
wire [15:0] sp_out;

//status register
wire cf,zf,nf,vf,sf,hf,ltf,gtf;
wire cf_out;

//instruction register
wire [15:0] instruction;

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
wire [2:0] sr_bit_idx;
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

//program bus
wire [15:0] pbus_in_data;

//data bus
wire [15:0] dbus_in_data;

state_control u_state_control (
    .clock(clock),
    .resetb(resetb),
    .halt(halt),
    .t1(t1),
    .t2(t2),
    .t3(t3),
    .t4(t4),
    .t5(t5)
);

program_counter u_program_counter (
    .clock(clock),
    .resetb(resetb),
    .pc_in(dbus_in_data),
    .pc_wr_en(pc_wr_en),
    .pc_sel(pc_sel),
    .t1(t1),
    .t3(t3),
    .t5(t5),
    .offset(offset),
    .next_pc(next_pc)
);

stack_pointer u_stack_pointer (
    .clock(clock),
    .resetb(resetb),
    .t2(t2),
    .t5(t5),
    .sp_sel(sp_sel),
    .sp_wr_en(sp_wr_en),
    .sp_out(sp_out)
);

status_register u_status_register (
    .clock(clock),
    .resetb(resetb),
    .t3(t3),
    .t5(t3),                
    .sreg_wr_en(sreg_wr_en),    
    .sr_bit_en(sr_bit_en),   
    .sr_bit_sel(sr_bit_sel),  
    .sr_bit_idx(sr_bit_idx), 
    .alu_cf(alu_cf),
    .alu_zf(alu_zf),
    .alu_nf(alu_nf),
    .alu_vf(alu_vf),
    .alu_sf(alu_sf),
    .alu_hf(alu_hf),
    .alu_ltf(alu_ltf),
    .alu_gtf(alu_gtf),
    .cf(cf),
    .zf(zf),          
    .nf(nf),         
    .vf(vf),
    .sf(sf),
    .hf(hf), 
    .ltf(ltf),         
    .gtf(gtf),         
    .cf_out(cf_out)       
);

instruction_register u_instruction_register (
    .clock(clock),
    .resetb(resetb),
    .t1(t1),
    .branch_en(branch_en),
    .pbus_in_data(pbus_in_data),
    .instruction(instruction)
);

instruction_decoder u_instruction_decoder (
    .clock(clock),
    .resetb(resetb)
);

register u_register (
    .clock(clock),
    .resetb(resetb)
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