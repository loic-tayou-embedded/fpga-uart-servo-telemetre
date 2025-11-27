-- UART_RX_tb.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity UART_RX_tb is
-- ---------------------------------------
	end UART_RX_tb;

-- ---------------------------------------
    Architecture UART_RX_tb_RTL of UART_RX_tb is
-- ---------------------------------------

signal CLK      : std_logic;
signal RST      : std_logic;
signal Data_RX  : std_logic_vector(7 downto 0);
signal RX       : std_logic;
signal End_RX   : std_logic;
signal Error_RX : std_logic;

signal Start_TX : std_logic;
signal Data_TX  : std_logic_vector(7 downto 0);
signal Data     : std_logic_vector(9 downto 0);
signal TX       : std_logic;
signal End_TX   : std_logic;

signal stop     : boolean := False;

-- -------------------------------------

begin

UART_RX_pm :	Entity work.UART_RX
				Generic map(
								Fclock    => 1E8, -- System Clock Freq in Hertz
								BAUD_RATE => 1E5
							)
				Port map(     
							CLK      => CLK,
							RST      => RST,
							Data_RX  => Data_TX,
							RX       => RX,
							Error_RX => Error_RX,
							End_RX   => Start_TX
						);
						
UART_TX_pm :	Entity work.UART_TX
				Generic map(
								Fclock    => 1E8, -- System Clock Freq in Hertz
								BAUD_RATE => 1E5
							)
				Port map(     
							CLK      => CLK,
							RST      => RST,
							Start_TX => Start_TX,
							Data_TX  => Data_TX,
							TX       => TX,
							End_TX   => End_TX
						);

CLOCK_PROCESS : process
				begin
					while not stop loop
						CLK <= '0';
						wait for 5 ns;
						CLK <= '1';
						wait for 5 ns;
					end loop;
					wait;
				end process;
				
STIMULI :	process
			begin
				Data <= "1011111110";
				RST  <= '1';
				RX   <= '1';
				wait for 100 ns;
				RST  <= '0';
				for i in 0 to 9 loop
					RX <= Data(i);
					wait for 10 us;
				end loop;
				wait until End_TX = '1';
				stop <= True;
				wait;
			end process;
			
end UART_RX_tb_RTL;

