--ANDRES MENDEZ CORTEZ
--A01751729
--MAQUINA DE ESTADOS PARA CONTROLAR EL PULSO SINCRONO VERTICAL
library ieee;
use ieee.std_logic_1164.all;

--para garantizar que se activen al mismo tiempo se liga el clock, reset y start
--cuenta necesaria para ver en que estado está
--salida indica que estado es
--el pulso de sincronia vertical tambien sale
entity XSINCVGA is 
	port( CLOCK,RESET,START: in std_logic;
			XCOUNT,YCOUNT: in std_logic_vector(9 downto 0);	
			COLORC,COLORF: in std_logic_vector(3 downto 0);
			YSTATE: in std_logic_vector(1 downto 0);
			R,G,B: out std_logic_vector(3 downto 0);
			HSINC: out std_logic);
end entity;

architecture RTL of XSINCVGA is 
	type STATES is (IDLE,PS,BP,VIS,FP);
	signal EDO,EDOF: STATES;
	begin
	P0: process(RESET,CLOCK) is--Flip flop controlado por el reloj y puede ser reseteado
		begin
		if RESET='0' then   
			EDO<=IDLE;
		elsif CLOCK'event and CLOCK='1' then
			EDO<=EDOF;
		end if;
	end process;
	
	P1: process (EDO,START,XCOUNT) is --trancissiones de la maquina de estados empezando en el idle
	begin
		case EDO is
			when IDLE => if START='1' then
								EDOF<=PS;
							  else 
								EDOF<=IDLE;
							  end if;
							  
			when PS => if XCOUNT="0001011111" then
								EDOF<=BP;
							  else 
								EDOF<=PS;
							  end if;
							 
			when BP => if XCOUNT="0010001111" then
								EDOF<=VIS;
							  else 
								EDOF<=BP;
							  end if;
							  
			when VIS => if XCOUNT="1100001111" then
								EDOF<=FP;
							  else 
								EDOF<=VIS;
							  end if;
			
			when FP => if XCOUNT="1100011111" then
								EDOF<=IDLE;
							  else 
								EDOF<=FP;
							  end if;
		end case;
	end process;
	
	P2: process(EDO,YSTATE,YCOUNT,XCOUNT,COLORC,COLORF) is --Salidas de la maquina de estados
		begin
		case EDO is
			when IDLE => HSINC<='0';
						 R<="0000";
						 G<="0000";
						 B<="0000";
							
			
			when PS=> HSINC<='0';
						 R<="0000";
						 G<="0000";
						 B<="0000";
							
			when BP=> HSINC<='1';
						 R<="0000";
						 G<="0000";
						 B<="0000";
							
			when VIS=>HSINC<='1';
						if (YSTATE="00") or (YSTATE="01") or (YSTATE="11") then
							R<="0000";
							G<="0000";
							B<="0000";
						else
							if ((YCOUNT<="0100000011") and (YCOUNT>="0011101111")) and ((XCOUNT>="011100"&COLORC) and (XCOUNT<="011101"&COLORF))then 
								R<="1111";
								G<="1111";
								B<="1111";
							else
								R<="1111";
								G<="0000";
								B<="0000";
							end if;
						end if;
			when FP=> HSINC<='1';
						 R<="0000";
						 G<="0000";
						 B<="0000";
			
	
		end case;
	end process;
	
	
end architecture;

