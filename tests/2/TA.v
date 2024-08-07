module ta(
	input wire clk,
	input wire rst,

	input wire enable,
	input wire training_sel,

	input wire literal_in,
	input wire type_feedback, 
	input wire clause_result,

	input wire rand_in,

	output wire done,
	output reg rand_out,
	output reg ta_result,
);


	logic [2:0] internal_weight;

	enum int unsigned {INIT, INFERENCE, TRAIN, FEEDBACK, OUT} state;

	always @(posedge clk) begin
		if (rst) begin
			done <= 1'b0;
			rand_out <= 1'b0;
			ta_result <= 1'b0;
			internal_weight <= 3'b000;
		end else if(enable && !training_sel) begin
			case (state)
				INIT: begin

				end
				INFERENCE: begin

				end
				OUT: begin

				end
		end else if(enable && training_sel) begin

		end
	end


end
