-- UART_FSM_TX.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity UART_FSM_TX is
-- ---------------------------------------
    Port(     
			CLK      : In std_logic;
            RST      : In std_logic;  
            Tick_bit : In std_logic;
			Start    : In std_logic;
			Data     : In std_logic_vector(7 downto 0);
			TX       : Out std_logic;
			end_TX   : Out std_logic
		);
end UART_FSM_TX;

-- ---------------------------------------
    Architecture UART_FSM_TX_RTL of UART_FSM_TX is
-- ---------------------------------------

Type state is (E1, E2, E3, E4, E5);
signal etatActuel : state := E1;
signal Trame      : std_logic_vector(9 downto 0);

-- -------------------------------------

begin

	process (RST,CLK)
	variable cnt: Natural := 0;
	begin
		if (RST = '1') then	
			end_TX    <= '0';
			TX        <= '1';
			cnt       := 0;
			etatActuel<= E1;
		elsif rising_edge (CLK) then
			case etatActuel is
				when E1 =>
					if (Start = '1') then
						etatActuel <= E2;
						Trame      <= '1' & Data & '0';
					end if;
				when E2 =>
					if(Tick_bit = '1') then
						TX <= Trame(cnt);
						etatActuel <= E3;
					end if;
				when E3 =>
					cnt := cnt + 1;
					etatActuel <= E4;
				when E4 =>
					if(Tick_bit = '1') then
						if(cnt = 10) then
							end_TX    <= '1';
							etatActuel <= E5;
						else
							TX <= Trame(cnt);
							etatActuel <= E3;
						end if;
					end if;
				when E5 =>
					end_TX    <= '0';
					TX        <= '1';
					cnt       := 0;
					etatActuel<= E1;
			end case;
		end if;
	end process;

end UART_FSM_TX_RTL;

