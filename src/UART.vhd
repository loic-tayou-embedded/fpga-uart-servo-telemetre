-- UART.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity UART is
-- ---------------------------------------
	Generic(
				Fclock 	  : positive := 50E6; -- System Clock Freq in Hertz
				BAUD_RATE : positive := 115200
		   );
	Port(
			CLK      : In std_logic;
			RST      : In std_logic;
			RX       : In std_logic;
			Start_TX : In std_logic;
			Data_RX  : Out std_logic_vector(7 downto 0);
			End_RX   : Out std_logic;
			Error_RX : Out std_logic;
			TX       : Out std_logic;
			End_TX   : Out std_logic;
			Data_TX  : In std_logic_vector(7 downto 0)
		);
	end UART;

-- ---------------------------------------
    Architecture UART_RTL of UART is
-- ---------------------------------------

-- -------------------------------------

begin

UART_RX_pm :	Entity work.UART_RX
				Generic map(
								Fclock    => Fclock, -- System Clock Freq in Hertz
								BAUD_RATE => BAUD_RATE
							)
				Port map(     
							CLK      => CLK,
							RST      => RST,
							Data_RX  => Data_RX,
							RX       => RX,
							Error_RX => Error_RX,
							End_RX   => End_RX
						);
						
UART_TX_pm :	Entity work.UART_TX
				Generic map(
								Fclock    => Fclock, -- System Clock Freq in Hertz
								BAUD_RATE => BAUD_RATE
							)
				Port map(     
							CLK      => CLK,
							RST      => RST,
							Start_TX => Start_TX,
							Data_TX  => Data_TX,
							TX       => TX,
							End_TX   => End_TX
						);
			
end UART_RTL;

