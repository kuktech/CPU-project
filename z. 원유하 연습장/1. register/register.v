module register (
input wire clock,
input wire reset_b,

input wire reg_dt_sel,
input wire exe_32,
input wire reg_wr_en,

input wire mem_wr_en,
input wire mem_rd_en,

input wire operand_en,

input wire ld_value_en,

input wire sp_rd_en,
input wire sp_wr_en,

input wire t2,
input wire t5,

input wire [2:0] des_reg,
input wire [2:0] src_reg,

input wire [15:0] alu_result0,
input wire [15:0] alu_result1,

input wire [15:0] dbus_in_data,

input wire [7:0] value,

output reg [15:0] r_operand,
output reg [15:0] l_operand,

output reg [15:0] push_rs,

output reg [15:0] mar,
output reg [15:0] mbr
);
reg [15:0] r0 = 16'b0; 
reg [15:0] r1 = 16'b0; 
reg [15:0] r2 = 16'b0; 
reg [15:0] r3 = 16'b0; 
reg [15:0] r4 = 16'b0; 
reg [15:0] r5 = 16'b0; 
reg [15:0] r6 = 16'b0; 
reg [15:0] r7 = 16'b0; 

always @(posedge clock or negedge reset_b) begin
    if(!reset_b)begin
        r0 <= 16'b0;
        r1 <= 16'b0;
        r2 <= 16'b0;
        r3 <= 16'b0;
        r4 <= 16'b0;
        r5 <= 16'b0;
        r6 <= 16'b0;
        r7 <= 16'b0;
    end
    else if(t2)begin
     if(mem_wr_en)begin
        case (des_reg)
            3'b000: mar <= r0;
            3'b001: mar <= r1;
            3'b010: mar <= r2;
            3'b011: mar <= r3;
            3'b100: mar <= r4;
            3'b101: mar <= r5;
            3'b110: mar <= r6;
            3'b111: mar <= r7;
            default: mar <= 16'b0;
        endcase
          case (src_reg)
            3'b000: mbr <= r0; 
            3'b001: mbr <= r1;
            3'b010: mbr <= r2;
            3'b011: mbr <= r3;
            3'b100: mbr <= r4;
            3'b101: mbr <= r5;
            3'b110: mbr <= r6;
            3'b111: mbr <= r7;
            default: mbr <= 16'b0;
        endcase
    end
      else if(mem_rd_en)begin
        case (src_reg)
            3'b000: mar <= r0; 
            3'b001: mar <= r1;
            3'b010: mar <= r2;
            3'b011: mar <= r3;
            3'b100: mar <= r4;
            3'b101: mar <= r5;
            3'b110: mar <= r6;
            3'b111: mar <= r7;
            default: mar <= 16'b0;
        endcase
    end
     else if(operand_en)begin
        case (src_reg)
            3'b000: r_operand <= r0;
            3'b001: r_operand <= r1;
            3'b010: r_operand <= r2;
            3'b011: r_operand <= r3;
            3'b100: r_operand <= r4;
            3'b101: r_operand <= r5;
            3'b110: r_operand <= r6;
            3'b111: r_operand <= r7;
            default: r_operand <= 16'b0;
        endcase
        case (des_reg)
            3'b000: l_operand <= r0;
            3'b001: l_operand <= r1;
            3'b010: l_operand <= r2;
            3'b011: l_operand <= r3;
            3'b100: l_operand <= r4;
            3'b101: l_operand <= r5;
            3'b110: l_operand <= r6;
            3'b111: l_operand <= r7;
            default: l_operand <= 16'b0;
        endcase
    end
     else if(sp_wr_en)begin
        case (src_reg)
            3'b000: mbr <= r0; 
            3'b001: mbr <= r1;
            3'b010: mbr <= r2;
            3'b011: mbr <= r3;
            3'b100: mbr <= r4;
            3'b101: mbr <= r5;
            3'b110: mbr <= r6;
            3'b111: mbr <= r7;
            default: mbr <= 16'b0;
        endcase
     end
    end
     else if (t5 && reg_wr_en) begin
        if(exe_32 && reg_dt_sel)begin
         case (des_reg)
            3'b000: {r0,r1} <= {alu_result0,alu_result1};
            3'b001: {r0,r1} <= {alu_result0,alu_result1};
            3'b010: {r2,r3} <= {alu_result0,alu_result1};
            3'b011: {r2,r3} <= {alu_result0,alu_result1};
            3'b100: {r4,r5} <= {alu_result0,alu_result1};
            3'b101: {r4,r5} <= {alu_result0,alu_result1};
            3'b110: {r6,r7} <= {alu_result0,alu_result1};
            3'b111: {r6,r7} <= {alu_result0,alu_result1};
            default: {r0,r1} <= {alu_result0,alu_result1};
        endcase
        end
    
     else if(reg_dt_sel)begin
        case (des_reg)
            3'b000: r0 <= alu_result0;
            3'b001: r1 <= alu_result0;
            3'b010: r2 <= alu_result0;
            3'b011: r3 <= alu_result0;
            3'b100: r4 <= alu_result0;
            3'b101: r5 <= alu_result0;
            3'b110: r6 <= alu_result0;
            3'b111: r7 <= alu_result0;
            default: r0 <= alu_result0;
        endcase
     end
     else if(!reg_dt_sel)begin
        case (des_reg)
            3'b000: r0 <= dbus_in_data;
            3'b001: r1 <= dbus_in_data;
            3'b010: r2 <= dbus_in_data;
            3'b011: r3 <= dbus_in_data;
            3'b100: r4 <= dbus_in_data;
            3'b101: r5 <= dbus_in_data;
            3'b110: r6 <= dbus_in_data;
            3'b111: r7 <= dbus_in_data;
            default: r0 <= dbus_in_data;
        endcase
     end
     else if(ld_value_en)begin
         case (des_reg)
            3'b000: r0 <= {8'b00000,value};
            3'b001: r1 <= {8'b00000,value};
            3'b010: r2 <= {8'b00000,value};
            3'b011: r3 <= {8'b00000,value};
            3'b100: r4 <= {8'b00000,value};
            3'b101: r5 <= {8'b00000,value};
            3'b110: r6 <= {8'b00000,value};
            3'b111: r7 <= {8'b00000,value};
            default: r0 <= {8'b00000,value};
        endcase
     end
      else if(sp_rd_en)begin
         case (des_reg)
            3'b000: r0 <= dbus_in_data;
            3'b001: r1 <= dbus_in_data;
            3'b010: r2 <= dbus_in_data;
            3'b011: r3 <= dbus_in_data;
            3'b100: r4 <= dbus_in_data;
            3'b101: r5 <= dbus_in_data;
            3'b110: r6 <= dbus_in_data;
            3'b111: r7 <= dbus_in_data;
            default: r0 <= dbus_in_data;
        endcase
     end
end
end

endmodule