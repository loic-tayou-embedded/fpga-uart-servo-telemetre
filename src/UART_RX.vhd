-- UART_RX.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity UART_RX is
-- ---------------------------------------
    Generic(
				Fclock 		: positive := 50E6; -- System Clock Freq in Hertz
				BAUD_RATE	: positive := 115200
		   );
	Port(     
			CLK        : In std_logic;
            RST        : In std_logic;
			RX         : In std_logic;
			Data_RX    : Out std_logic_vector(7 downto 0);
			Error_RX   : Out std_logic;
			End_RX     : Out std_logic
		);
end UART_RX;

-- ---------------------------------------
    Architecture UART_RX_RTL of UART_RX is
-- ---------------------------------------

signal Tick_half_bit, Clear_FDIV, RST_FDIV : std_logic;

-- -------------------------------------

begin

RST_FDIV <= RST or Clear_FDIV;

FDIV_pmRX :	Entity work.FDIV
			Generic map(
							Fclock    => Fclock, -- System Clock Freq in Hertz
							BAUD_RATE => BAUD_RATE * 2
					   )
			Port map(     
						CLK      => CLK,
						RST      => RST_FDIV,
						Tick_bit => Tick_half_bit
					);

UART_FSM_RX_pm :	Entity work.UART_FSM_RX
					Port map(     
								CLK      	  => CLK,
								RST           => RST,  
								Tick_half_bit => Tick_half_bit,
								Clear_FDIV    => Clear_FDIV,
								Data     	  => Data_RX,
								RX       	  => RX,
								error_RX      => Error_RX,
								end_RX        => End_RX
							);

end UART_RX_RTL;

