`include "FixedPointALU.v"

module Node #(
    parameter node_id = 1
) (
    input wire clk,
    input wire reset,
    input wire verlet_state, 
    input wire fix_constraint_state, 
    input wire[31:0] x_fix_constraint, 
    input wire[31:0] y_fix_constraint,
    output wire[31:0] x_pos,
    output wire[31:0] y_pos,
    output reg finish
);

real gravity = 0.3; 

wire verlet_x, verlet_y, fix_const_x, fix_const_y;
wire in_x_ff, in_y_ff;


reg[31:0] x; reg [31:0] y; reg [31:0] px; reg [31:0] py;
assign x_pos = x;
assign y_pos = y;

integer base_x = 200;   
integer dist = 10;

reg[31:0] fix_2 = 32'h00002000 ;
reg[31:0] fix_gravity = 32'h000004cd ;
reg[1:0] operation_1 = 2;
reg[1:0] operation_2 = 1; 
wire[31:0] x_mult_2_out; 
wire[31:0] y_mult_2_out;
wire[31:0] next_x;
wire [31:0] py_sub_gravity;
wire[31:0] next_y; 

assign py_sub_gravity = py - gravity;
FixedPointALU x_mult_2(x,fix_2, operation_1,x_mult_2_out);
FixedPointALU twoX_sub_px(x_mult_2_out, px,operation_2, next_x);
FixedPointALU y_mult_2(y, fix_2, operation_1,y_mult_2_out);
FixedPointALU twoY_sub(y_mult_2_out, py_sub_gravity, operation_2,next_y);

always @(posedge clk) begin: calc_verlet_x
    if (reset) begin
        x <= base_x;
        px <= base_x; 
        y <= dist * node_id;
        py <= dist * node_id;
        finish <= 1; 
    end else if(verlet_state)begin
        px <= x; 
        py <= y;
        x <= next_x;
        y <= next_y;
        finish <= 1;
    end else if(fix_constraint_state)begin
        x <= x_fix_constraint;
        y <= y_fix_constraint;
        finish <= 1;
    end else begin
        finish <= 0;
    end
 
end

endmodule
