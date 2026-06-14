module top (
input wire clock,
input wire resetb,

input wire [15:0] program_data,
input wire [15:0] dmem_rdata,

output wire [15:0] pbus_in_address,
output wire prdb_pin,
output wire pcsb_pin,

output wire [15:0] mbr,
output wire [15:0] mar,
output wire drdb_pin,
output wire dwrb_pin,
output wire dcsb_pin
);
wire t1;
wire t2;
wire t3;
wire t4;
wire t5;

wire [15:0] next_pc;

wire [15:0] sp_out;

wire cf;
wire zf;
wire nf;
wire vf;
wire sf;
wire hf;
wire gtf;
wire ltf;
wire cf_out;

wire [15:0] instruction;

wire [2:0] des_reg;
wire [2:0] src_reg;
wire [10:0] offset;
wire [7:0] reg_value;
wire [2:0] alu_value;
wire [2:0] n;
wire halt;
wire move;
wire mv_sp;
wire hxhg;
wire swap;
wire push;
wire pop;
wire reg_dt_sel;
wire reg_wr_en;
wire ldl_value_en;
wire ldh_value_en;
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

wire [15:0] r_operand;
wire [15:0] l_operand;
wire [15:0] rd_data;
wire [15:0] rs_data;

wire [15:0] alu_result0;
wire [15:0] alu_result1;

wire alu_cf;
wire alu_zf;
wire alu_nf;
wire alu_vf;
wire alu_sf;
wire alu_hf;
wire alu_gtf;
wire alu_ltf;

wire [15:0] pbus_in_data;

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
    .mv_sp(mv_sp),
    .rs_data(rs_data),
    .sp_out(sp_out)
);

status_register u_status_register (
    .clock(clock),
    .resetb(resetb),
    .t3(t3),
    .t5(t5),                
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
    .pbus_in_data(pbus_in_data),
    .instruction(instruction)
);

register u_register (
    .clock(clock),
    .resetb(resetb),
    .reg_dt_sel(reg_dt_sel),
    .exe_32(exe_32),
    .reg_wr_en(reg_wr_en),
    .mem_wr_en(mem_wr_en),
    .mem_rd_en(mem_rd_en),
    .operand_en(operand_en),
    .ldl_value_en(ldl_value_en),
    .ldh_value_en(ldl_value_en),
    .move(move),
    .mv_sp(mv_sp),
    .hxhg(hxhg),
    .swap(swap),
    .push(push),
    .pop(pop),
    .n(n),
    .clr(clr),
    .set(set),
    .t3(t3),
    .t5(t5),
    .des_reg(des_reg),
    .src_reg(src_reg),
    .alu_result0(alu_result0),
    .alu_result1(alu_result1),
    .dbus_in_data(dbus_in_data),
    .value(reg_value),
    .r_operand(r_operand),
    .l_operand(l_operand),
    .rd_data(rd_data),
    .rs_data(rs_data)
);

instruction_decoder u_instruction_decoder (
    .clock(clock),
    .resetb(resetb),
    .t2(t2),
    .instruction(instruction),
    .cf(cf),
    .zf(zf),          
    .nf(nf),         
    .vf(vf),
    .sf(sf),
    .hf(hf), 
    .ltf(ltf),         
    .gtf(gtf),  
    .des_reg(des_reg),
    .src_reg(src_reg),
    .offset(offset),
    .reg_value(reg_value),
    .alu_value(alu_value), 
    .n(n),
    .halt(halt),
    .move(move),
    .mv_sp(mv_sp),
    .hxhg(hxhg),
    .swap(swap),
    .push(push),
    .pop(pop),
    .reg_dt_sel(reg_dt_sel),
    .reg_wr_en(reg_wr_en),
    .ldl_value_en(ldl_value_en),
    .ldh_value_en(ldh_value_en),
    .mem_rd_en(mem_rd_en),
    .mem_wr_en(mem_wr_en),
    .dbus_access(dbus_access),
    .dbus_addr_sel(dbus_addr_sel),
    .dbus_data_sel(dbus_data_sel),
    .sp_sel(sp_sel),
    .sp_wr_en(sp_wr_en),
    .operand_en(operand_en),
    .sreg_wr_en(sreg_wr_en),
    .sr_bit_en(sr_bit_en),
    .sr_bit_sel(sr_bit_sel),
    .sr_bit_idx(sr_bit_idx),
    .exe_32(exe_32),
    .pc_wr_en(pc_wr_en),
    .pc_sel(pc_sel),
    .clr(clr),
    .set(set),
    .alu_sel(alu_sel),
    .alu_sop(alu_sop)  
);

alu u_alu (
    .t3(t3),
    .l_operand(l_operand),
    .r_operand(r_operand),
    .alu_sel(alu_sel),    
    .alu_sop(alu_sop),     
    .shift_amt(alu_value),  
    .alu_cf_in(cf_out),            
    .alu_result0(alu_result0),
    .alu_result1(alu_result1),
    .alu_cf(alu_cf),
    .alu_zf(alu_zf),
    .alu_nf(alu_nf),   
    .alu_vf(alu_vf),
    .alu_sf(alu_sf),
    .alu_hf(alu_hf), 
    .alu_gtf(alu_gtf),  
    .alu_ltf(alu_ltf)
);

program_bus u_program_bus (
    .clock(clock),
    .resetb(resetb),
    .t1(t1),
    .t2(t2),
    .pc(next_pc),
    .program_data(program_data),
    .prdb_pin(prdb_pin),
    .pcsb_pin(pcsb_pin),
    .pbus_in_address(pbus_in_address),
    .pbus_in_data(pbus_in_data)
);

data_bus u_data_bus (
    .clock(clock),
    .resetb(resetb),
    .t3(t3),
    .t4(t4),
    .t5(t5),
    .dbus_access(dbus_access),
    .dbus_addr_sel(dbus_addr_sel),
    .dbus_data_sel(dbus_data_sel),
    .rd_data(rd_data),
    .rs_data(rs_data),
    .sp_in(sp_out),
    .pc_in(next_pc),
    .dmem_rdata(dmem_rdata),    
    .drdb_pin(drdb_pin),
    .dwrb_pin(dwrb_pin),
    .dcsb_pin(dcsb_pin),
    .mbr(mbr),
    .mar(mar),
    .dbus_in_data(dbus_in_data)
);

endmodule