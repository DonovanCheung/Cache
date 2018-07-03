`timescale 1ns / 1ns

module cache_tb;

	// Cache Inputs
	reg [7:0] pr_dout;
	reg [5:0] pr_addr;
	reg       pr_rd;
	reg       pr_wr;
  
	
	reg clk;
	reg rst;

	// Cache Outputs and memory inputs
	
	wire        cvalid;
	wire        stall;
	wire [7:0] 	pr_din;
	wire [15:0] mem_din;
	wire 	   	mem_rd;
	wire 	   	mem_wr;
	wire [4:0] 	mem_addr;
	
	// mem output
	wire [15:0] mem_dout;
	wire 	   	mem_done;
	
	localparam Initial			= 	4'b0001,
				StartProcess	=	4'b0010,
				WaitForFlush	=	4'b0100,
				WaitForFetch	=	4'b1000;
	localparam CYCLETIME = 2;
	reg [16*8:0] state_string;
	
	// Instantiate the Unit Under Test (UUT)
	Cache cache (
		.clk(clk), 
		.reset(rst),
		.pr_din(pr_din), 
		.pr_dout(pr_dout), 
		.pr_addr(pr_addr), 
		.pr_rd(pr_rd), 
		.pr_wr(pr_wr), 
		.cvalid(cvalid),
		.mem_din(mem_din), 
		.mem_dout(mem_dout), 
		.mem_done(mem_done), 
		.mem_rd(mem_rd), 
		.mem_wr(mem_wr),
		.mem_addr(mem_addr)
	);
	
	Memory #(.INIT_FILE("datamem.txt")) dmem (	
		.addr(mem_addr), 
		.memread(mem_rd), 
		.memwrite(mem_wr), 
		.wdata(mem_din),
		.clk(clk),
		.rst(rst),
		.rdata(mem_dout),
		.mem_done(mem_done)
	);

	always @ (cache.state) // report the state in text format in the waveform
	begin : report_state	
		case (cache.state)
		Initial: 			state_string  =   "  Initial      ";
		StartProcess: 		state_string  =   "  StartProc    ";
		WaitForFlush: 		state_string  =   "  WaitForFlush ";
		WaitForFetch: 		state_string  =   "  WaitForFetch ";
		default: 			state_string  =   "  Unknown	  ";
		
		endcase
	end
	
  always #1 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		#CYCLETIME;
		rst = 0;
		#CYCLETIME;
		
		// LW @1; 1
		pr_dout = 8'bzzzzzzzz;
		pr_addr=1; 
		pr_rd=1;
		//CYCLETIME;
		
		wait(cvalid && !clk);
		wait(cvalid && clk);
		
		// SW 12@9;  
		pr_addr=9;
		pr_rd=0; 
		pr_wr=1;
		pr_dout=12;
		//#CYCLETIME;
		
		wait(cvalid && !clk);
		wait(cvalid && clk);
		
		// SW 13@9;
		pr_addr=9;
		pr_rd=0;
		pr_wr=1;
		pr_dout=13;
		//#CYCLETIME;
		
		wait(cvalid && !clk);
		wait(cvalid && clk);
		
		// SW 14@1; WB 3-> mem[9], 4-> cache
		pr_addr=1;
		pr_rd=0;
		pr_wr=1;
		pr_dout=14;
		//#CYCLETIME;
		
		wait(cvalid && !clk);
		wait(cvalid && clk);
		
		// LW @9; WB 4-> mem[1], mem[9]=3 -> Cache  
		pr_dout = 8'bzzzzzzzz;
		pr_addr=9;
		pr_rd=1;
		pr_wr=0;
		//#CYCLETIME;
		
		wait(cvalid && !clk);
		wait(cvalid && clk);
		
		// LW @8; Hit!
		pr_dout = 8'bzzzzzzzz;
		pr_addr=8;
		pr_rd=1;
		pr_wr=0;
		//#CYCLETIME;
		
		wait(cvalid && !clk);
		wait(cvalid && clk);
		
		// SW 17@4 ; Miss
		pr_addr=4;
		pr_rd=0;
		pr_wr=1;
		pr_dout=17;
		//#CYCLETIME;
		
		wait(cvalid && !clk);
		wait(cvalid && clk);
		
		// LW @9 ; Hit
		pr_dout = 8'bzzzzzzzz;
		pr_addr=9;
		pr_rd=1;
		pr_wr=0;
		//#CYCLETIME;
		
		wait(cvalid && !clk);
		wait(cvalid && clk);
		
		// LW @13 ; WB 17->mem[4], mem[13] -> Cache
		pr_dout = 8'bzzzzzzzz;
		pr_addr=13;
		pr_rd=1;
		pr_wr=0;
		//#CYCLETIME;
		
		wait(cvalid && !clk);
		wait(cvalid && clk);
		
		pr_dout = 8'bzzzzzzzz;
		pr_rd=0;
		pr_wr=0;

		
		#1000;
		$stop();
	end
      
endmodule



