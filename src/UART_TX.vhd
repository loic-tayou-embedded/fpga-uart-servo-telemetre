-- UART_TX.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity UART_TX is
-- ---------------------------------------
    Generic(
				Fclock 		: positive := 50E6; -- System Clock Freq in Hertz
				BAUD_RATE	: positive := 115200
		   );
	Port(     
			CLK      : In std_logic;
            RST      : In std_logic;  
			Start_TX : In std_logic;
			Data_TX  : In std_logic_vector(7 downto 0);
			TX       : Out std_logic;
			End_TX   : Out std_logic
		);
end UART_TX;

-- ---------------------------------------
    Architecture UART_TX_RTL of UART_TX is
-- ---------------------------------------

signal Tick_bit : std_logic;

-- -------------------------------------

begin

FDIV_pm :	Entity work.FDIV
			Generic map(
							Fclock    => Fclock, -- System Clock Freq in Hertz
							BAUD_RATE => BAUD_RATE
					   )
			Port map(     
						CLK      => CLK,
						RST      => RST,
						Tick_bit => Tick_bit
					);

UART_FSM_TX_pm :	Entity work.UART_FSM_TX
					Port map(     
								CLK      => CLK,
								RST      => RST,  
								Tick_bit => Tick_bit,
								Start    => Start_TX,
								Data     => Data_TX,
								TX       => TX,
								end_TX   => End_TX
							);

end UART_TX_RTL;

