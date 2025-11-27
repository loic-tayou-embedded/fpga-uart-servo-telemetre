-- UART_TX_tb.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity UART_TX_tb is
-- ---------------------------------------
	end UART_TX_tb;

-- ---------------------------------------
    Architecture UART_TX_tb_RTL of UART_TX_tb is
-- ---------------------------------------

signal CLK      : std_logic;
signal RST      : std_logic;  
signal Start_TX : std_logic;
signal Data_TX  : std_logic_vector(7 downto 0);
signal TX       : std_logic;
signal End_TX   : std_logic;
signal stop     : boolean := False;

-- -------------------------------------

begin

UART_TX_pm :	Entity work.UART_TX
				Generic map(
							Fclock    => 50E6, -- System Clock Freq in Hertz
							BAUD_RATE => 115200
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
				Data_TX <= "01111111";
				RST     <= '1';
				wait for 10 ns;
				RST     <= '0';
				Start_TX <= '1';
				wait for 10 ns;
				Start_TX <= '0';
				wait until End_TX = '1';
				stop <= True;
				wait;
			end process;
			
end UART_TX_tb_RTL;

