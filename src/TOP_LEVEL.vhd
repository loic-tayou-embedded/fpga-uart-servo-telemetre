-- TOP_LEVEL.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity TOP_LEVEL is
-- ---------------------------------------
	Generic(
				Fclock 	  : positive := 50E6; -- System Clock Freq in Hertz
				BAUD_RATE : positive := 115200;
				Tclock 	  : positive := 20;
				Fcompteur : positive := 1;
				PULSE     : positive := 1E5
		   );
	Port(     
			CLOCK_50 : In std_logic;
            KEY      : In std_logic_vector(3 downto 0);
			SW       : In std_logic_vector(8 downto 0);
			LEDR     : Out std_logic_vector(8 downto 0);
			GPIO_1   : Inout std_logic_vector (35 downto 0)
		);
	end TOP_LEVEL;

-- ---------------------------------------
    Architecture TOP_LEVEL_RTL of TOP_LEVEL is
-- ---------------------------------------

type ascii_lut is array (0 to 15) of std_logic_vector(7 downto 0);
constant ASCII_HEX : ascii_lut := (
  x"30", -- 0
  x"31", -- 1
  x"32", -- 2
  x"33", -- 3
  x"34", -- 4
  x"35", -- 5
  x"36", -- 6
  x"37", -- 7
  x"38", -- 8
  x"39", -- 9
  x"41", -- A
  x"42", -- B
  x"43", -- C
  x"44", -- D
  x"45", -- E
  x"46"  -- F
);

signal Start_TX, PWM, Trig, RX, TX, End_RX, End_TX, Output_Ready : std_logic;
signal Data_TX, Data_RX, Distance  : std_logic_vector(7 downto 0);

signal nb_chiffre       : integer range 0 to 3 := 0;
signal d0, d1, d2       : integer range 0 to 9 := 0;
signal cmd_servo_moteur : std_logic_vector(7 downto 0);

-- -------------------------------------

begin

UART_pm :	Entity work.UART
			Generic map(
							Fclock    => Fclock, -- System Clock Freq in Hertz
							BAUD_RATE => BAUD_RATE
					   )
			Port map(     
						CLK      => CLOCK_50,
						RST      => not KEY(0),
						RX       => RX,
						Start_TX => Start_TX,
						Data_RX  => Data_RX,
						End_RX   => End_RX,
						Data_TX  => Data_TX,  --ASCII_HEX(to_integer(unsigned(SW(3 downto 0)))),
						TX       => TX,
						End_TX   => End_TX
					);
						
SERVO_pm :	Entity work.SERVO
			Generic map(
							Fclock   => 50E6, -- System Clock Freq in Hertz
							FREQ_PWM => 50,
							FREQ_MIN => 1E3,
							FREQ_MAX => 5E2
						)
			Port map(     
						CLK   => CLOCK_50,
						RST   => not KEY(0),
						ANGLE => cmd_servo_moteur,
						PWM   => PWM
					);
					
TELEMETRE_pm :	Entity work.TELEMETRE
				Generic map(
								Fclock 	  => Fclock, -- System Clock Freq in Hertz
								Tclock    => Tclock,
								Fcompteur => Fcompteur,
								PULSE     => PULSE
						   )
				Port map(     
							CLK          => CLOCK_50,
							RST          => not KEY(0),  
							Echo         => GPIO_1(4),
							Trig         => Trig,
							Distance     => Distance,
							Output_Ready => Output_Ready
						);
						
SYSTEM :	process(CLOCK_50, KEY(0))
				variable dist : integer range 0 to 255;
				variable cnt  : integer range 0 to 3 := 0;
				variable b    : integer;
				variable angle_servo : integer range 0 to 180;
			begin
				if(not KEY(0) = '1') then
					nb_chiffre  <= 0;
					angle_servo := 0;
					cnt         := 0;
				elsif rising_edge(CLOCK_50) then
					case SW(1 downto 0) is
						when "00" =>
						when "01" =>
							if(End_RX = '1') then
								b := to_integer(unsigned(Data_RX));
								if((b>=48) and (b<=57)) then  -- '0'..'9'
									case nb_chiffre is
										when 0 => d0 <= b-48; nb_chiffre <= 1;
										when 1 => d1 <= b-48; nb_chiffre <= 2;
										when 2 =>
											d2 <= b-48; nb_chiffre <= 0;
											-- convertir d0 d1 d2
											if((10*(d0*10 + d1) + (b-48)) > 180) then
												angle_servo := 180;
											else
												angle_servo := (d0*100 + d1*10 + (b-48));
											end if;
											cmd_servo_moteur <= std_logic_vector(to_unsigned(angle_servo, 8));
											when others => nb_chiffre <= 0;
										end case;
								else
									nb_chiffre <= 0; -- reset si caractÃ¨re non numÃ©rique
								end if;
							end if;
						when "10" =>
							Start_TX <= '0';
							case cnt is
								when 0 =>
									if(Output_Ready = '1') then
										dist     := to_integer(unsigned(Distance));
										cnt      := 3;
										Data_TX  <= ASCII_HEX(dist / 100);
										Start_TX <= '1';
									end if;
								when 1 =>
									if(Output_Ready = '0') then
										cnt     := cnt - 1;
									end if;
								when 2 => 
									if(End_TX = '1') then
										Start_TX <= '1';
										Data_TX  <= ASCII_HEX(dist rem 10);
										cnt      := cnt - 1;
									end if;
								when 3 =>
									if(End_TX = '1') then
										Start_TX <= '1';
										Data_TX  <= ASCII_HEX((dist rem 100) / 10);
										cnt      := cnt - 1;
									end if;
								when others => cnt := 0;
							end case;
						when "11" =>
							cmd_servo_moteur <= Distance;
					end case;
				end if;
			end process;
			
LEDR     <= '0' & cmd_servo_moteur when SW(1 downto 0) = "01" else
			Output_Ready & Distance when SW(1 downto 0) = "10" or SW(1 downto 0) = "11" else
			(others => '0');
GPIO_1(3)<= Trig when SW(1 downto 0) = "10" or SW(1 downto 0) = "11" else
			'Z';
GPIO_1(2)<= PWM when SW(1 downto 0) = "01" or SW(1 downto 0) = "11" else
			'Z';
RX       <= GPIO_1(1) when SW(1 downto 0) = "01" else
			'1';
GPIO_1(0)<= TX when SW(1 downto 0) = "10" else
			'Z';
			
end TOP_LEVEL_RTL;

