`timescale 1ns / 1ns
module Cache (
	input 			 	clk,
	input 			 	reset,
	input [7:0]		 	pr_dout,
	output[7:0] 	 	pr_din,
	input [5:0] 	 	pr_addr,
	input 			 	pr_rd,
	input 			 	pr_wr,
	output              cvalid,
	input [15:0]		mem_dout,
	output reg [15:0] 	mem_din,
	input 	    	 	mem_done,
	output reg 	  	 	mem_rd,
	output reg 	   	 	mem_wr,
	output reg [4:0] 	mem_addr);

	reg [2:0] tag [0:3]; // TAG RAM with 4 3-bit wide tags
	reg [7:0] data[0:7];	// DATA RAM with 8 8-bit wide data (half word)
	reg [3:0] valid ;		// Array of 4 valid bits for each tag
	reg [3:0] dirty ;		// Array of 4 dirty bits for each tag
	integer i;
	
	reg [3:0] state;
	wire hit;
	wire [1:0] pr_cblk;
    wire       pr_word;
	wire [2:0] pr_tag;
	wire [4:0] pr_mem_addr;


	// Address breakdown
	assign pr_cblk = pr_addr[2:1];
    assign pr_word = pr_addr[0];
	assign pr_tag = pr_addr[5:3];				
	assign pr_mem_addr = pr_addr[5:1];

	localparam Initial		= 	4'b0001,
			   StartProcess	=	4'b0010,
			   WaitForFlush	=	4'b0100,
			   WaitForFetch	=	4'b1000;

	// Completed...You may change if needed but we recommend leaving this	
	
	// Either a read or write has been requested by the processor
	assign req = (pr_rd | pr_wr);
	// Desired tag matches with located tag & it is valid
	assign hit = (tag[pr_cblk] == pr_tag) & valid[pr_cblk] ;	 
	// Data at index {pr_cblk, pr_word} regardless of hit
	assign pr_din = data [{pr_cblk, pr_word}];
	// Completed/valid task
	assign cvalid = req & hit;


	
	// For each state consider any changes necessary to the internal and 
	// output signals:
	//   state, valid and dirty bits, tags and data, and the memory signals:
	//    mem_rd, mem_wr, mem_din, and mem_addr
	// You can access a desired element of the tag, valid, or dirty array by  
	//   using array indexes (e.g. tag[pr_cblk]). 
	// Remember you can contenate signals like:  { data[15:8], pr_data[7:0] } 
	always @(posedge clk)
	begin
	if(reset)
		state<=Initial;
	else
		case (state)
		
			Initial:
			begin
				valid<=4'b0000;
				dirty<=4'b0000;
				for (i=0; i<4; i=i+1)
					tag[i]<=0;
				
				mem_rd<=0;
				mem_wr<=0;
				
				state <= StartProcess;
			end
			
			StartProcess:
			begin
				// Determine if you have a request and whether it hits
				//  or misses and if the block needs to be written back/flushed

//				mem_rd <= 0;	// Reset mem_rd and mem_wr unconditionally
//				mem_wr <= 0;
				if (req)
				begin
					if (hit)
					begin
						if (pr_wr)
						begin
							data[{pr_cblk,pr_word}] <= pr_dout; // Or the full 16 bits
							dirty[pr_cblk] <= 1;
						end
					end
					else // miss
					begin
						if (dirty[pr_cblk])	// Go to Flush
						begin
							mem_wr <= 1; 
							// mem_addr <= {pr_mem_addr, 0};
							mem_din[7:0] <= data[{pr_cblk,1'b0}]; // or just the lower bits of mem_dout?
							mem_din[15:8] <= data[{pr_cblk,1'b1}];
						end
						else if (!dirty[pr_cblk])	// Go to Fetch
						begin
							mem_rd <= 1;
							mem_addr <= pr_mem_addr;
						end
					end
				end
				
				
				if (req && !hit && dirty[pr_cblk])	// cvalid instead of hit?
					state <= WaitForFlush;
				if (req && !hit && !dirty[pr_cblk])
					state <= WaitForFetch;

			end

			// Hint you only need to update signals when the flush is complete 
			WaitForFlush:
			begin
				if (mem_done)
				begin
					mem_wr <= 0;
					mem_rd <= 1;
					mem_addr <= pr_mem_addr;
					state <= WaitForFetch;		
				end
			
			end			
			
			// Hint you only need to update signals when the flush is complete 
			WaitForFetch:
			begin
				if (mem_done)
				begin
					data[{pr_cblk,1'b0}] <= mem_dout[7:0];
					data[{pr_cblk,1'b1}] <= mem_dout[15:8];
					mem_rd <= 0;
					valid[pr_cblk] <= 1;
					tag[pr_cblk] <= pr_addr[5:3];
					dirty[pr_cblk] <= 1'b0;	
					if (pr_wr)
					begin
						data[{pr_cblk,pr_word}] <= pr_dout[7:0];
						dirty[pr_cblk] <= 1;
					end
				end
				
				if (mem_done)
					state <= StartProcess;
					
			end
			
		endcase	
	end
endmodule