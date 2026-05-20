`ifndef ALU_SV
`define ALU_SV
`include "parameters.sv"

module ALU( bus1, bus2, ALUout, opcode, CarryOut, Negative, Zero, oVerflow) ;
  input [0:DATABUS_MSB] bus1 ;
  input [0:DATABUS_MSB] bus2 ;
  input [0:3] opcode ;
  
  output reg [0:DATABUS_MSB] ALUout ;
  output reg CarryOut ;
  output reg Negative ;
  output reg Zero ;
  output reg oVerflow ;
  
  
  reg [0:DATABUS_MSB + 1] temp;
  
  always @ ( * ) begin
    ALUout = 0;
    CarryOut = 0;
    Negative = 0;
    Zero = 0;
    oVerflow = 0;
    temp = 0;
    
    if (opcode == ALU_ADD) begin
      ALUout = bus1 + bus2;
      temp = bus1 + bus2;
      Negative = ALUout[0];
      CarryOut = (bus1 + bus2) >> DATABUS_SIZE;
      oVerflow = ((bus1[0] == bus2[0]) && (ALUout[0] != bus1[0]));
      if (ALUout == 0)
        	Zero = 1;
      	else
        	Zero = 0;    
    end
    
    else if (opcode == ALU_SUB) begin
      ALUout = bus1 - bus2;
      temp = bus1 - bus2;
      Negative = ALUout[0];
      CarryOut = 0;
      oVerflow = ((bus1[0] != bus2[0]) && (ALUout[0] != bus1[0]));
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
    
    else if ( opcode == ALU_SHIFT_LEFT ) begin
      if( bus2 > DATABUS_MSB )
        ALUout = 0;
      if (bus2 < 2 ) 
        temp = 1;
      else
        temp = bus2;
      ALUout = (bus1 << temp);
      CarryOut = 0;
      oVerflow = 0;
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
    
    else if ( opcode == ALU_SHIFT_RIGHT ) begin
      if (bus2 > 35)
        temp = 35;
      if (bus2 < 2)
        temp = 1;
      else
        temp = bus2;
      ALUout = (bus1 >> temp);
      CarryOut = 0;
      oVerflow = 0;
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
        
    else if (opcode == ALU_AND) begin
      ALUout = bus1 & bus2;
      CarryOut = 0;
      oVerflow = 0;
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
      
    else if (opcode == ALU_OR) begin
   	  ALUout = bus1 | bus2;
      CarryOut = 0;
      oVerflow = 0;
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
    
    else if (opcode == ALU_EQUAL) begin
      ALUout = bus1 == bus2;
      CarryOut = 0;
      oVerflow = 0;
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
      
    else if (opcode == ALU_LESSTHANEQUAL) begin
      ALUout = (bus1 <= bus2);
      CarryOut = 0;
      oVerflow = 0;
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
      
    else if (opcode == ALU_GREATTHANEQUAL) begin
      ALUout = (bus1 >= bus2);
      CarryOut = 0;
      oVerflow = 0;
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
    
    else if (opcode == ALU_LESSTHAN) begin
      ALUout = (bus1 < bus2);
      CarryOut = 0;
      oVerflow = 0;
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
    
    else if (opcode == ALU_GREATTHAN) begin
      ALUout = (bus1 > bus2);
      CarryOut = 0;
      oVerflow = 0;
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
    
    else if (opcode == ALU_NOT) begin
      ALUout = ~bus1;
      CarryOut = 0;
      oVerflow = 0;
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
    
    else if (opcode == ALU_ADDCARRY) begin
      temp = (bus1 + bus2 + CarryOut);
      CarryOut = temp[0];
      ALUout = temp[1:DATABUS_MSB+1];
      oVerflow = ((bus1[0] == bus2[0]) && (ALUout[0] != bus1[0]));
      Negative = ALUout[0];
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
    
    else if (opcode == ALU_REVERSESUB) begin
      temp = (bus2 - bus1);
      ALUout = temp[1:DATABUS_MSB+1];
      CarryOut = 0;
      Negative = ALUout[0];
      oVerflow = ((bus2[0] != bus1[0]) && (ALUout[0] != bus2[0]));
      if (ALUout == 0)
        Zero = 1;
      else
        Zero = 0;
    end
  end    
endmodule 

`endif