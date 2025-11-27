-- SERVO.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity SERVO is
-- ---------------------------------------
	Generic(
				Fclock   : positive := 50E6; -- System Clock Freq in Hertz
				FREQ_PWM : positive := 50;
				FREQ_MIN : positive := 1E3;
				FREQ_MAX : positive := 5E2
		   );
	Port(     
			CLK   : In std_logic;
			RST   : In std_logic;
            ANGLE : In std_logic_vector(7 downto 0);
			PWM   : Out std_logic
		);
end SERVO;

-- ---------------------------------------
    Architecture SERVO_RTL of SERVO is
-- ---------------------------------------

constant NB_COUPS : Positive := Fclock / FREQ_PWM;
constant PULSE_MIN: positive := Fclock / FREQ_MIN;
constant PULSE_MAX: positive := Fclock / FREQ_MAX;
signal cnt        : integer range 0 to NB_COUPS;
signal pulse      : integer range 0 to NB_COUPS;

-- -------------------------------------

begin

SERVO_ps :	process(CLK, RST)
			begin
				if(RST = '1') then
					cnt <= 0;
				elsif rising_edge(CLK) then
					if(cnt = NB_COUPS - 1) then
						cnt <= 0;
					else
						cnt <= cnt + 1;
					end if;
				end if;
			end process;
			

pulse <= PULSE_MIN + (to_integer(unsigned(ANGLE)) * (PULSE_MAX - PULSE_MIN)) / 180;
PWM   <= '1' when cnt >= 0 and cnt <= pulse - 1 else
	     '0';

end SERVO_RTL;

