-- TELEMETRE_tb.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity TELEMETRE_tb is
-- ---------------------------------------
	end TELEMETRE_tb;

-- ---------------------------------------
    Architecture TELEMETRE_tb_RTL of TELEMETRE_tb is
-- ---------------------------------------
    
signal CLK          : std_logic;
signal RST          : std_logic;  
signal Echo         : std_logic;
signal Trig         : std_logic;
signal Distance     : std_logic_vector(7 downto 0);
signal Output_Ready : std_logic;

signal stop : boolean := False;

-- -------------------------------------

begin

TELEMETRE_pm :	Entity work.TELEMETRE
				Generic map(
								Fclock 	  => 1E8, -- System Clock Freq in Hertz
								Tclock    => 10,
								Fcompteur => 1E6,
								PULSE     => 1E7
						   )
				Port map(     
							CLK          => CLK,
							RST          => RST,  
							Echo         => Echo,
							Trig         => Trig,
							Distance     => Distance,
							Output_Ready => Output_Ready
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
				RST <= '1';
				wait for 10 ns;
				RST <= '0';
				wait for 300 ns;
				Echo <= '1';
				wait for 300 ns;
				Echo <= '0';
				wait for 500 ns;
				stop <= True;
				wait;
			end process;

end TELEMETRE_tb_RTL;

