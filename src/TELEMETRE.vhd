-- TELEMETRE.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity TELEMETRE is
-- ---------------------------------------
    Generic(
				Fclock 	  : positive := 50E6; -- System Clock Freq in Hertz
				Tclock 	  : positive := 20;
				Fcompteur : positive := 1;
				PULSE     : positive := 1E5
		   );
	Port(     
			CLK          : In std_logic;
            RST          : In std_logic;  
            Echo         : In std_logic;
			Trig         : Out std_logic;
			Distance     : Out std_logic_vector(7 downto 0);
			Output_Ready : Out std_logic
		);
end TELEMETRE;

-- ---------------------------------------
    Architecture TELEMETRE_RTL of TELEMETRE is
-- ---------------------------------------

Type state is (E1, E2, E3, E4);
signal etatActuel : state := E1; 

constant CNT_PULSE  : positive := Fclock / PULSE;
constant CNT_MESURE : positive := Fclock / Fcompteur;

-- -------------------------------------

begin

	process (RST,CLK)
	variable cnt          : Natural := 0;
	variable temps_mesure : Natural := 0;
	begin
		if (RST = '1') then	
			Output_Ready <= '0';
			Distance     <= (others => '0');
			cnt          := 0;
			temps_mesure := 0;
			etatActuel   <= E1;
		elsif rising_edge (CLK) then
			case etatActuel is
				when E1 =>
					Trig <= '1';
					cnt := cnt + 1;
					if (cnt = CNT_PULSE) then
						etatActuel <= E2;
						Trig       <= '0';
					end if;
				when E2 =>
					cnt := cnt + 1;
					if (Echo = '1') then
						etatActuel   <= E3;
						temps_mesure := temps_mesure + 1;
					end if;
				when E3 =>
					cnt := cnt + 1;
					temps_mesure := temps_mesure + 1;
					if (Echo = '0') then
						Distance     <= std_logic_vector(to_unsigned((17 * temps_mesure * Tclock) / 100, 8));
						Output_Ready <= '1';
						etatActuel   <= E4;
					end if;
				when E4 =>
					cnt := cnt + 1;
					if(cnt >= CNT_MESURE) then
						etatActuel   <= E1;
						Output_Ready <= '0';
						cnt          := 0;
						temps_mesure := 0;
					end if;
			end case;
		end if;
	end process;

end TELEMETRE_RTL;

