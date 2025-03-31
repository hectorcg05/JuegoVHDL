--ANDRES MENDEZ CORTEZ
--A01751729
--MAQUINA DE ESTADOS PARA CONTROLAR EL PULSO SINCRONO VERTICAL
library ieee;
use ieee.std_logic_1164.all;

--para garantizar que se activen al mismo tiempo se liga el clock, reset y start
--cuenta necesaria para ver en que estado está
--salida indica que estado es
--el pulso de sincronia vertical tambien sale
entity YSINCVGA is 
	port( CLOCK,RESET,START: in std_logic;
			YCOUNT: in std_logic_vector(9 downto 0);
			YSTATE: out std_logic_vector(1 downto 0);
			VSINC: out std_logic);
end entity;

architecture RTL of YSINCVGA is 
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
	
	P1: process (EDO,START,YCOUNT) is --trancissiones de la maquina de estados empezando en el idle
	begin
		case EDO is
			when IDLE => if START='1' then
								EDOF<=PS;
							  else 
								EDOF<=IDLE;
							  end if;
							  
			when PS => if YCOUNT="0000000001" then
								EDOF<=BP;
							  else 
								EDOF<=PS;
							  end if;
							  
			when BP => if YCOUNT="0000100010" then
								EDOF<=VIS;
							  else 
								EDOF<=BP;
							  end if;
							  
			when VIS => if YCOUNT="1000000010" then
								EDOF<=FP;
							  else 
								EDOF<=VIS;
							  end if;
			
			when FP => if YCOUNT="1000001100" then
								EDOF<=IDLE;
							  else 
								EDOF<=FP;
							  end if;
		end case;
	end process;
	
	P2: process(EDO) is --Salidas de la maquina de estados
		begin
		case EDO is
			
			when PS=> YSTATE<="00";
							VSINC<='0';
							
			when BP=> YSTATE<="01";
							VSINC<='1';
							
			when VIS=> YSTATE<="10";
							VSINC<='1';
							
			when FP=> YSTATE<="11";
							VSINC<='1';
			
			when others=> null;
		end case;
	end process;
	
	
end architecture;

