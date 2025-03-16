module baudPLL(
		input CLK, RST, SET,
		input [31:0] BAUDRATE,
		output reg BAUD_TICK, BAUD_TICK_X32
	);
	
	reg [31:0] baudrate_reg, baud_count_reg, oversample32_count_reg;
	
	always@(posedge CLK or negedge RST) begin
		if (~RST) begin
			baudrate_reg <= 32'b0;
			baud_count_reg <= ~{32'b0};
			oversample32_count_reg <= 32'b0;
			BAUD_TICK <= 1'b0;
			BAUD_TICK_X32 <= 1'b0;
			
		end else begin
			if (SET) begin
				baudrate_reg <= BAUDRATE;
				baud_count_reg <= 32'b0;
				oversample32_count_reg <= 32'b0;
				BAUD_TICK <= 1'b0;
				BAUD_TICK_X32 <= 1'b0;
			
			end else begin
				if (baud_count_reg == baudrate_reg - 32'b1) begin
					baud_count_reg <= 32'b0;
					BAUD_TICK <= 1'b1;
				end else begin
					baud_count_reg <= baud_count_reg + 32'd1;
					BAUD_TICK <= 1'b0;
				end
				
				if (oversample32_count_reg == (baudrate_reg >> 5) - 32'b1) begin
					oversample32_count_reg <= 32'b0;
					BAUD_TICK_X32 <= 1'b1;
				end else begin
					oversample32_count_reg <= oversample32_count_reg + 32'd1;
					BAUD_TICK_X32 <= 1'b0;
				end
			end
		end
	end
endmodule 