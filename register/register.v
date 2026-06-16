module register (
input wire clock,
input wire resetb,

input wire reg_dt_sel,
input wire exe_32,
input wire reg_wr_en,

input wire mem_wr_en,
input wire mem_rd_en,

input wire operand_en,

input wire ldl_value_en,
input wire ldh_value_en,

input wire move,
input wire mv_sp,
input wire hxhg,
input wire swap,

input wire push,
input wire pop,

input wire [2:0] n,
input wire clr,
input wire set,

input wire t3,
input wire t5,

input wire [2:0] des_reg,
input wire [2:0] src_reg,

input wire [15:0] alu_result0,
input wire [15:0] alu_result1,

input wire [15:0] dbus_in_data,

input wire [7:0] value,

output reg [15:0] r_operand,
output reg [15:0] l_operand,

output reg [15:0] rd_data,
output reg [15:0] rs_data
);
reg [15:0] r0 = 16'b0; 
reg [15:0] r1 = 16'b0; 
reg [15:0] r2 = 16'b0; 
reg [15:0] r3 = 16'b0; 
reg [15:0] r4 = 16'b0; 
reg [15:0] r5 = 16'b0; 
reg [15:0] r6 = 16'b0; 
reg [15:0] r7 = 16'b0; 

reg [15:0] temp_des = 16'b0;
reg [15:0] temp_src = 16'b0;

always @(*) begin
    case (src_reg)
        3'b000: temp_src = r0;
        3'b001: temp_src = r1;
        3'b010: temp_src = r2;
        3'b011: temp_src = r3;
        3'b100: temp_src = r4;
        3'b101: temp_src= r5;
        3'b110: temp_src= r6;
        3'b111: temp_src = r7;
        default: temp_src = 16'b0;
    endcase
    case (des_reg)
        3'b000: temp_des = r0;
        3'b001: temp_des = r1;
        3'b010: temp_des = r2;
        3'b011: temp_des = r3;
        3'b100: temp_des = r4;
        3'b101: temp_des= r5;
        3'b110: temp_des= r6;
        3'b111: temp_des = r7;
        default: temp_des = 16'b0;
    endcase
end

always @(posedge clock or negedge resetb) begin
    if(!resetb)begin
        r0 <= 16'b0;
        r1 <= 16'b0;
        r2 <= 16'b0;
        r3 <= 16'b0;
        r4 <= 16'b0;
        r5 <= 16'b0;
        r6 <= 16'b0;
        r7 <= 16'b0;
    end
    else if(t3)begin
     if(mem_wr_en)begin
        case (des_reg)
            3'b000: rd_data <= r0;
            3'b001: rd_data <= r1;
            3'b010: rd_data <= r2;
            3'b011: rd_data <= r3;
            3'b100: rd_data <= r4;
            3'b101: rd_data <= r5;
            3'b110: rd_data <= r6;
            3'b111: rd_data <= r7;
            default: rd_data <= 16'b0;
        endcase
        case (src_reg)
            3'b000: rs_data <= r0; 
            3'b001: rs_data <= r1;
            3'b010: rs_data <= r2;
            3'b011: rs_data <= r3;
            3'b100: rs_data <= r4;
            3'b101: rs_data <= r5;
            3'b110: rs_data <= r6;
            3'b111: rs_data <= r7;
            default: rs_data <= 16'b0;
        endcase
    end
    else if(mem_rd_en)begin
        case (src_reg)
            3'b000: rs_data <= r0; 
            3'b001: rs_data <= r1;
            3'b010: rs_data <= r2;
            3'b011: rs_data <= r3;
            3'b100: rs_data <= r4;
            3'b101: rs_data <= r5;
            3'b110: rs_data <= r6;
            3'b111: rs_data <= r7;
            default: rs_data <= 16'b0;
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
    else if(push)begin
        case (src_reg)
            3'b000: rs_data <= r0; 
            3'b001: rs_data <= r1;
            3'b010: rs_data <= r2;
            3'b011: rs_data <= r3;
            3'b100: rs_data <= r4;
            3'b101: rs_data <= r5;
            3'b110: rs_data <= r6;
            3'b111: rs_data <= r7;
            default: rs_data <= 16'b0;
        endcase
     end
     else if(mv_sp)begin
        case (src_reg)
            3'b000: rs_data <= r0; 
            3'b001: rs_data <= r1;
            3'b010: rs_data <= r2;
            3'b011: rs_data <= r3;
            3'b100: rs_data <= r4;
            3'b101: rs_data <= r5;
            3'b110: rs_data <= r6;
            3'b111: rs_data <= r7;
            default: rs_data <= 16'b0;
        endcase
     end
    end
    else if (t5 && reg_wr_en) begin
         if(ldl_value_en)begin
            case (des_reg)
                3'b000: r0[7:0] <= value;
                3'b001: r1[7:0] <= value;
                3'b010: r2[7:0] <= value;
                3'b011: r3[7:0] <= value;
                3'b100: r4[7:0] <= value;
                3'b101: r5[7:0] <= value;
                3'b110: r6[7:0] <= value;
                3'b111: r7[7:0] <= value;
                default: r0[7:0] <= value;
            endcase
        end
        else if(ldh_value_en)begin
            case (des_reg)
                3'b000: r0[15:8] <= value;
                3'b001: r1[15:8] <= value;
                3'b010: r2[15:8] <= value;
                3'b011: r3[15:8] <= value;
                3'b100: r4[15:8] <= value;
                3'b101: r5[15:8] <= value;
                3'b110: r6[15:8] <= value;
                3'b111: r7[15:8] <= value;
                default: r0[15:8] <= value;
            endcase
        end
        else if(move) begin
            case (des_reg)
                3'b000: r0 <= temp_src;
                3'b001: r1 <= temp_src;
                3'b010: r2 <= temp_src;
                3'b011: r3 <= temp_src;
                3'b100: r4 <= temp_src;
                3'b101: r5 <= temp_src;
                3'b110: r6 <= temp_src;
                3'b111: r7 <= temp_src;
                default: r0 <= temp_src;
            endcase
        end
        else if(hxhg) begin
            case (des_reg)
                3'b000: r0 <= temp_src;
                3'b001: r1 <= temp_src;
                3'b010: r2 <= temp_src;
                3'b011: r3 <= temp_src;
                3'b100: r4 <= temp_src;
                3'b101: r5 <= temp_src;
                3'b110: r6 <= temp_src;
                3'b111: r7 <= temp_src;
                default: r0 <= temp_src;
            endcase
            case (src_reg)
                3'b000: r0 <= temp_des;
                3'b001: r1 <= temp_des;
                3'b010: r2 <= temp_des;
                3'b011: r3 <= temp_des;
                3'b100: r4 <= temp_des;
                3'b101: r5 <= temp_des;
                3'b110: r6 <= temp_des;
                3'b111: r7 <= temp_des;
                default: r0 <= temp_des;
            endcase
        end
        else if(swap) begin
            case (des_reg)
                3'b000: begin r0[15:8] <= r0[7:0]; r0[7:0] <= r0[15:8]; end 
                3'b001: begin r1[15:8] <= r1[7:0]; r1[7:0] <= r1[15:8]; end
                3'b010: begin r2[15:8] <= r2[7:0]; r2[7:0] <= r2[15:8]; end
                3'b011: begin r3[15:8] <= r3[7:0]; r3[7:0] <= r3[15:8]; end
                3'b100: begin r4[15:8] <= r4[7:0]; r4[7:0] <= r4[15:8]; end
                3'b101: begin r5[15:8] <= r5[7:0]; r5[7:0] <= r5[15:8]; end
                3'b110: begin r6[15:8] <= r6[7:0]; r6[7:0] <= r6[15:8]; end
                3'b111: begin r7[15:8] <= r7[7:0]; r7[7:0] <= r7[15:8]; end
                default: begin r0[15:8] <= r0[7:0]; r0[7:0] <= r0[15:8]; end
            endcase
        end
        else if (clr) begin
             case (des_reg)
                3'b000: begin r0[n] <= 16'b0; end 
                3'b001: begin r1[n] <= 16'b0; end 
                3'b010: begin r2[n] <= 16'b0; end 
                3'b011: begin r3[n] <= 16'b0; end 
                3'b100: begin r4[n] <= 16'b0; end 
                3'b101: begin r5[n] <= 16'b0; end 
                3'b110: begin r6[n] <= 16'b0; end 
                3'b111: begin r7[n] <= 16'b0; end 
                default: begin r0[n] <= 16'b0; end 
            endcase
        end
        else if (set) begin
              case (des_reg)
                3'b000: begin r0[n] <= 16'b1; end 
                3'b001: begin r1[n] <= 16'b1; end 
                3'b010: begin r2[n] <= 16'b1; end 
                3'b011: begin r3[n] <= 16'b1; end 
                3'b100: begin r4[n] <= 16'b1; end 
                3'b101: begin r5[n] <= 16'b1; end 
                3'b110: begin r6[n] <= 16'b1; end 
                3'b111: begin r7[n] <= 16'b1; end 
                default: begin r0[n] <= 16'b1; end 
            endcase
        end
        else if(reg_dt_sel)begin
            if(exe_32)begin
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
            else begin
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
        end
        else if(!reg_dt_sel && mem_rd_en)begin 
            if(pop)begin
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
            else begin
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
        else begin
            r0 <= r0;
            r1 <= r1;
            r2 <= r2;
            r3 <= r3;
            r4 <= r4;
            r5 <= r5;
            r6 <= r6;
            r7 <= r7;
        end
end
end

endmodule