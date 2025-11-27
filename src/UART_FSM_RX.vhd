-- UART_FSM_RX.vhd

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

-- ---------------------------------------
    Entity UART_FSM_RX is
-- ---------------------------------------
    Port(     
			CLK           : In std_logic;
            RST           : In std_logic;  
            Tick_half_bit : In std_logic;
			RX            : In std_logic;
			Clear_FDIV    : Out std_logic;
			Data          : Out std_logic_vector(7 downto 0);
			error_RX      : Out std_logic;
			end_RX        : Out std_logic
		);
end UART_FSM_RX;

-- ---------------------------------------
    Architecture UART_FSM_RX_RTL of UART_FSM_RX is
-- ---------------------------------------

Type state is (E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, Err);
signal etatActuel : state := E1;
signal Trame      : std_logic_vector(9 downto 0);

-- -------------------------------------

begin

	process (RST,CLK)
	variable cnt: Natural := 0;
	begin
		if (RST = '1') then	
			end_RX    <= '0';
			error_RX  <= '0';
			cnt       := 0;
			etatActuel<= E1;
		elsif rising_edge (CLK) then
			case etatActuel is
				when E1 =>
					if (RX = '0') then
						etatActuel <= E2;
						Clear_FDIV <= '1';
					end if;
				when E2 =>
					etatActuel <= E3;
					Clear_FDIV <= '0';
				when E3 =>
					if(Tick_half_bit = '1') then
						etatActuel <= E4;
					end if;
				when E4 =>
					if(RX = '0') then
						etatActuel <= E5;
					else
						error_RX   <= '1';
						etatActuel <= Err;
					end if;
				when E5 =>
					if(Tick_half_bit = '1') then
						etatActuel <= E6;
					end if;
				when E6 =>
					if(Tick_half_bit = '1') then
						Data(cnt)  <= RX;
						etatActuel <= E7;
					end if;
				when E7 =>
					if(Tick_half_bit = '1') then
						cnt := cnt + 1;
						if(cnt = 8) then
							etatActuel <= E8;
						else
							etatActuel <= E6;
						end if;
					end if;
				when E8 =>
					if(Tick_half_bit = '1') then
						etatActuel <= E9;
					end if;
				when E9 =>
					if(Tick_half_bit = '1') then
						etatActuel <= E10;
					end if;
				when E10 =>
					if(RX = '1') then
						end_RX     <= '1';
						etatActuel <= E11;
					else
						error_RX   <= '1';
						etatActuel <= Err;
					end if;
				when E11 =>
					end_RX    <= '0';
					error_RX  <= '0';
					cnt       := 0;
					etatActuel<= E1;
				when Err =>
					end_RX    <= '0';
					error_RX  <= '0';
					cnt       := 0;
					etatActuel<= E1;
			end case;
		end if;
	end process;

end UART_FSM_RX_RTL;

