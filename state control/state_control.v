module state_control(
input wire clock,
input wire resetb,

input wire halt,

output wire t1,
output wire t2,
output wire t3,
output wire t4,
output wire t5
);

reg [4:0] rotator = 5'b10000;
 
always @(posedge clock or negedge resetb) begin
   
    if(!resetb)begin
        rotator <= 5'b10000;
    end
    else if(halt)begin
        rotator <=5'b00000;
    end
    else begin
        case (rotator)
            5'b10000:  rotator <= 5'b01000;
            5'b01000:  rotator <= 5'b00100;
            5'b00100:  rotator <= 5'b00010;
            5'b00010:  rotator <= 5'b00001;
            5'b00001:  rotator <= 5'b10000;
            default:   rotator <= 5'b00000; 
        endcase
    end
end

assign {t1, t2, t3, t4, t5} = rotator;
endmodule
