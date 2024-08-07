module ta(
	input wire clk,
	input wire rst,

	input wire enable,
	input wire training_sel,

	input wire literal_in,
	input wire type_feedback, 
	input wire clause_result,

	input wire rand_clk,
	input wire rand_in,

	output wire ready,
	output wire done,
	output reg rand_out,
	output reg ta_result
);


	logic [2:0] internal_weight;

	enum logic [1:0] {INFERENCE, TRAIN, FEEDBACK, OUT} state;
	enum logic [1:0] {REW, PEN, IGN} train_state;

	assign ready = (state == INFERENCE);
	assign done = (state == OUT);

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			rand_out <= 1'b0;
			ta_result <= 1'b0;
			internal_weight <= 3'b000;
			state = INFERENCE;
		end else if(enable && !training_sel) begin
			case (state)
				INFERENCE: begin
					ta_result <= literal_in || (internal_weight > 3'b010);
					state <= OUT;
				end
				default: state <= INFERENCE;
			endcase
		end else if(enable && training_sel) begin
			case (state)
				INFERENCE: begin
					ta_result <= literal_in || (internal_weight > 3'b010);
					state <= TRAIN;
				end
				TRAIN: begin
					if (!type_feedback) begin
						if (!(clause_result) ^ (internal_weight > 3'b010)) begin
							train_state <= REW;
						end else if ((!clause_result) && (internal_weight > 3'b010)) begin
							train_state <= PEN;
						end else begin
							train_state <= literal_in == 1 ? PEN : REW; 
						end
					end else begin
						if (!(internal_weight > 3'b010) && clause_result && literal_in) begin
							train_state <= PEN;
						end else begin
							train_state <= IGN;
						end
					end
					state <= FEEDBACK;
				end
				FEEDBACK: begin
					if (!type_feedback) begin
						if (train_state == REW && (internal_weight < 3'b100)) begin
							internal_weight <= internal_weight + (1 & rand_out);
						end else if (train_state == PEN && (internal_weight > 3'b000)) begin
							internal_weight <= internal_weight - (1 & rand_out);
						end
					end else begin
						if (train_state == REW && (internal_weight < 3'b100)) begin
							internal_weight <= internal_weight + 1;
						end else if (train_state == PEN && (internal_weight > 3'b000)) begin
							internal_weight <= internal_weight - 1;
						end
	
					end
				end
				default: state <= INFERENCE;
			endcase
		end else if(!enable) begin
			state = INFERENCE;
		end
	end


	always @(posedge rand_clk or posedge rst) begin
		if(rst) begin
			rand_out <= 1'b0;
		end
	end


endmodule
