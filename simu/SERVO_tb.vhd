-- SERVO_tb.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity SERVO_tb is
-- ---------------------------------------
	end SERVO_tb;

-- ---------------------------------------
    Architecture SERVO_tb_RTL of SERVO_tb is
-- ---------------------------------------

signal CLK   : std_logic;
signal RST   : std_logic;
signal ANGLE : std_logic_vector(7 downto 0);
signal PWM   : std_logic;

signal stop  : boolean := False;

-- -------------------------------------

begin

SERVO_pm :	Entity work.SERVO
			Generic map(
							Fclock   => 100_000_000, -- System Clock Freq in Hertz
							FREQ_PWM => 100_000,
							FREQ_MIN => 1_000_000,
							FREQ_MAX => 500_000
						)
			Port map(     
						CLK   => CLK,
						RST   => RST,
						ANGLE => ANGLE,
						PWM   => PWM
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
				RST   <= '1';
				ANGLE <= std_logic_vector(to_unsigned(0,8));
				wait for 10 ns;
				RST   <= '0';

				wait for 20 us;
				
				ANGLE <= std_logic_vector(to_unsigned(90,8)); 
				wait for 20 us;
				
				ANGLE <= std_logic_vector(to_unsigned(180,8)); 
				wait for 20 us;
				
				stop <= True;
				wait;
			end process;
			
end SERVO_tb_RTL;

