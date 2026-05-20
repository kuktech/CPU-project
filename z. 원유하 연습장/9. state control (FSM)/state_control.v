module state_control(
input wire clock,
input wire reset_b,

output wire t1,
output wire t2,
output wire t3,
output wire t4,
output wire t5,

output wire pc_wr_en
);

reg [4:0] rotator = 5'b10000;
 
always @(posedge clock or negedge reset_b) begin
   
    if(!reset_b)begin
        rotator <= 5'b10000;
    end
    else begin
        case (rotator)
            5'b10000:  rotator <= 5'b01000;
            5'b01000:  rotator <= 5'b00100;
            5'b00100:  rotator <= 5'b00010;
            5'b00010:  rotator <= 5'b00001;
            5'b00001:  rotator <= 5'b10000;
            default:   rotator <= 5'b10000; 
        endcase
    end
end

assign {t1, t2, t3, t4, t5} = rotator;
assign pc_wr_en = t1 | t3 | t5;
endmodule