--ANDRES MENDEZ CORTEZ
--A01751729
--MAQUINA DE ESTADOS PARA CONTROLAR EL PULSO SINCRONO VERTICAL
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--para garantizar que se activen al mismo tiempo se liga el clock, reset y start
--cuenta necesaria para ver en que estado está
--salida indica que estado es
--el pulso de sincronia vertical tambien sale
entity XSINCVGABOX is 
	port( CLOCK,RESET,START,JUMP,SWF,SWB,VSINC,PER: in std_logic;
			XCOUNT,YCOUNT: in std_logic_vector(9 downto 0);	
			YSTATE: in std_logic_vector(1 downto 0);
			R,G,B: out std_logic_vector(3 downto 0);
			HSINC: out std_logic);
end entity;

architecture RTL of XSINCVGABOX is 
	type STATES is (IDLE, PS, BP, VIS, FP);
	signal EDO, EDOF: STATES;
	
	signal ENDGAME: std_logic:='0';
	signal CONT_END: integer := 0;
	signal linea_actual : integer range 0 to 525 := 0;
	-- Señales internas para colores
	signal R_FONDO, G_FONDO, B_FONDO: std_logic_vector(3 downto 0);
	signal R_CUADRADO, G_CUADRADO, B_CUADRADO: std_logic_vector(3 downto 0);
	signal R_V1, G_V1, B_V1: std_logic_vector(3 downto 0);
	signal R_V2, G_V2, B_V2: std_logic_vector(3 downto 0);
	signal R_CUADRADO2, G_CUADRADO2, B_CUADRADO2: std_logic_vector(3 downto 0);
	signal R_PLAT2, G_PLAT2, B_PLAT2: std_logic_vector(3 downto 0);
	signal R_ENEMY, G_ENEMY, B_ENEMY: std_logic_vector(3 downto 0);
	signal R_BALA, G_BALA, B_BALA: std_logic_vector(3 downto 0);
	signal R_ARO1, G_ARO1, B_ARO1: std_logic_vector(3 downto 0);
	signal R_ARO2, G_ARO2, B_ARO2: std_logic_vector(3 downto 0);
	signal R_ARO3, G_ARO3, B_ARO3: std_logic_vector(3 downto 0);
	signal R_MIX, G_MIX, B_MIX: std_logic_vector(3 downto 0);
	
	--primer cubo
	signal X_CENTRO: integer := 0; -- Posición inicial en X
	signal LADO: integer := 20; -- Tamaño del cuadrado
	signal VELOCIDAD: integer := 3; -- Cuántos píxeles se mueve
	signal VELY : integer := 0;  -- Velocidad vertical
   signal JUMPING : std_logic := '0'; -- Estado de salto
	signal POSY : integer := 250; -- Posición Y inicial (encima del suelo)
	signal VIDASONIC: integer:=1;
	signal COLECT: integer:=0;
	--vidas mostradas
	signal X_VIDA1: integer:=160;
	signal Y_VIDA: integer:=40;
	signal X_VIDA2: integer:=175;
	--primer plataforma
	signal X_CENTRO2: integer := 290;
	signal POSY2: integer := 200;
	signal ALTURA2: integer:= 10;
	signal LADO2: integer:=40;
	
	--segunda plataforma
	signal X_CENTROP2: integer := 590;
	signal POSYP2: integer := 220;
	signal ALTURAP2: integer:= 10;
	signal LADOP2: integer:=40;
	
	--ENEMIGO
	signal X_CENTROE: integer :=0;
	signal POSYE: integer := 120;
	signal ALTURAE: integer:= 35;
	signal LADOE: integer:=35;
	signal VELENEMY: integer := 6; -- Cuántos píxeles se mueve
	signal VIDAS: integer:=19; -- El enemigo aparece inicialmente
	signal DIREC: std_logic;
	
	--bala
	signal X_CBALA: integer:=440;
	signal POSYBALA: integer:=120;
	signal BALA_ON: std_logic:='0';
	signal GRAVBALA: integer:=7;
	signal CNT_DISP: integer := 0;
   signal INTERVALO: integer := 25; -- Cada cierto tiempo el enemigo dispara
	--aro1
	signal X_ARO1: integer:= 315;
	signal Y_ARO1: integer:=195;
	signal X_ARO1DIF,Y_ARO1DIF,DIST_A1: integer;
	signal VIS_A1: std_logic:='1';
	signal RADARO1: integer:=15;
	--aro2
	signal X_ARO2: integer:= 615;
	signal Y_ARO2: integer:=215;
	signal X_ARO2DIF,Y_ARO2DIF,DIST_A2: integer;
	signal RADARO2: integer:=15;
	signal VIS_A2: std_logic:='1';
	--aro3
	signal X_ARO3: integer:= 215;
	signal Y_ARO3: integer:=285;
	signal X_ARO3DIF,Y_ARO3DIF,DIST_A3: integer;
	signal RADARO3: integer:=15;
	signal VIS_A3: std_logic:='1';
	signal REXT: integer:=8;
	signal RINT: integer:=4;
--fisica
	signal GROUND_LEVEL : integer := 293; -- Nivel del césped
	constant PISO : integer := 293; -- Nivel de piso absoluto
	constant GRAVEDAD: integer := 1; -- Aceleración por gravedad
	constant JUMP_FORCE: integer := -14; -- Fuerza inicial de salto

begin
	-- Flip-Flop para el estado
	P0: process(RESET, CLOCK) is
	begin
		if RESET = '0' then
			EDO <= IDLE;
		elsif CLOCK'event and CLOCK = '1'  then
			EDO <= EDOF;
		end if;
	end process;

	-- Transiciones de la Máquina de Estados
	P1: process (EDO, START, XCOUNT) is
	begin
		case EDO is
			when IDLE =>
				if START = '1' then
					EDOF <= PS;
				else
					EDOF <= IDLE;
				end if;

			when PS =>
				if XCOUNT = "0001011111" then
					EDOF <= BP;
				else
					EDOF <= PS;
				end if;

			when BP =>
				if XCOUNT = "0010001111" then
					EDOF <= VIS;
				else
					EDOF <= BP;
				end if;

			when VIS =>
				if XCOUNT = "1100001111" then
					EDOF <= FP;
				else
					EDOF <= VIS;
				end if;

			when FP =>
				if XCOUNT = "1100011111" then
					EDOF <= IDLE;
				else
					EDOF <= FP;
				end if;
		end case;
	end process;
	
	P2: process(EDO) is --Salidas de la maquina de estados
		begin
		case EDO is
			when IDLE => HSINC<='0';

			when PS=> HSINC<='0';

			when BP=> HSINC<='1';
							
			when VIS=>HSINC<='1';
						
			when FP=> HSINC<='1';
			end case;
	end process;

	-- Proceso para Pintar el Fondo
	P3: process(XCOUNT, YCOUNT, EDO) is
	begin
		if EDO = VIS then
			if ENDGAME='0' then
				
				-- ESCENARIO PINTADO
				if (to_integer(unsigned(YCOUNT))<=290) then
					R_FONDO <= "1000"; -- Color azul claro
					G_FONDO <= "1100";
					B_FONDO <= "1111";
				elsif (to_integer(unsigned(YCOUNT))) >= 290 and (to_integer(unsigned(YCOUNT))) < 300 then
							  if (to_integer(unsigned(XCOUNT)) / 10 mod 2 = (to_integer(unsigned(YCOUNT)) /10 mod 2)) then
									R_FONDO <= "0010"; -- Verde más oscuro
									G_FONDO <= "1100";
									B_FONDO <= "0000";
							  else
									R_FONDO <= "0011"; -- Verde más claro
									G_FONDO <= "1110";
									B_FONDO <= "0000";
							  end if;
				
				elsif to_integer(unsigned(YCOUNT)) >=300 then
								if ((to_integer(unsigned(XCOUNT)) / 20) mod 2 = (to_integer(unsigned(YCOUNT)) / 20) mod 2) then
									 -- Cuadro oscuro
									 R_FONDO <= "1001"; -- Marrón oscuro
									 G_FONDO <= "0101";
									 B_FONDO <= "0000";
								else
									 -- Cuadro claro
									 R_FONDO <= "1110"; -- Marrón claro
									 G_FONDO <= "1010";
									 B_FONDO <= "0000";
								end if;			
								
				-- TERMINA ESCENARIO
				
				end if;	
			elsif ENDGAME='1' and VIDAS>0 then
						if (unsigned(XCOUNT) >= to_unsigned(0, 10) 
							  AND unsigned(XCOUNT) < to_unsigned(800, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(0, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(30+linea_actual, 10))then
								 R_FONDO <= "0001";  
								 G_FONDO <= "0001";
								 B_FONDO <= "0001";
						elsif (to_integer(unsigned(YCOUNT))<=290) then
							R_FONDO <= "1000"; -- Color azul claro
							G_FONDO <= "1100";
							B_FONDO <= "1111";
						elsif (to_integer(unsigned(YCOUNT))) >= 290 and (to_integer(unsigned(YCOUNT))) < 300 then
									  if (to_integer(unsigned(XCOUNT)) / 10 mod 2 = (to_integer(unsigned(YCOUNT)) /10 mod 2)) then
											R_FONDO <= "0010"; -- Verde más oscuro
											G_FONDO <= "1100";
											B_FONDO <= "0000";
									  else
											R_FONDO <= "0011"; -- Verde más claro
											G_FONDO <= "1110";
											B_FONDO <= "0000";
									  end if;
						
						elsif to_integer(unsigned(YCOUNT)) >=300 then
										if ((to_integer(unsigned(XCOUNT)) / 20) mod 2 = (to_integer(unsigned(YCOUNT)) / 20) mod 2) then
											 -- Cuadro oscuro
											 R_FONDO <= "1001"; -- Marrón oscuro
											 G_FONDO <= "0101";
											 B_FONDO <= "0000";
										else
											 -- Cuadro claro
											 R_FONDO <= "1110"; -- Marrón claro
											 G_FONDO <= "1010";
											 B_FONDO <= "0000";
										end if;
						end if;
			else
						if (unsigned(XCOUNT) >= to_unsigned(0, 10) 
							  AND unsigned(XCOUNT) < to_unsigned(800, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(0, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(30+linea_actual, 10))then
								 R_FONDO <= "1101";  
								 G_FONDO <= "1101";
								 B_FONDO <= "1101";
						elsif (to_integer(unsigned(YCOUNT))<=290) then
							R_FONDO <= "1000"; -- Color azul claro
							G_FONDO <= "1100";
							B_FONDO <= "1111";
						elsif (to_integer(unsigned(YCOUNT))) >= 290 and (to_integer(unsigned(YCOUNT))) < 300 then
									  if (to_integer(unsigned(XCOUNT)) / 10 mod 2 = (to_integer(unsigned(YCOUNT)) /10 mod 2)) then
											R_FONDO <= "0010"; -- Verde más oscuro
											G_FONDO <= "1100";
											B_FONDO <= "0000";
									  else
											R_FONDO <= "0011"; -- Verde más claro
											G_FONDO <= "1110";
											B_FONDO <= "0000";
									  end if;
						
						elsif to_integer(unsigned(YCOUNT)) >=300 then
										if ((to_integer(unsigned(XCOUNT)) / 20) mod 2 = (to_integer(unsigned(YCOUNT)) / 20) mod 2) then
											 -- Cuadro oscuro
											 R_FONDO <= "1001"; -- Marrón oscuro
											 G_FONDO <= "0101";
											 B_FONDO <= "0000";
										else
											 -- Cuadro claro
											 R_FONDO <= "1110"; -- Marrón claro
											 G_FONDO <= "1010";
											 B_FONDO <= "0000";
										end if;
						end if;
			end if;
			
				
		else
			R_FONDO <= "0000";
			G_FONDO <= "0000";
			B_FONDO <= "0000";
		end if;
	end process;
		--actualizar los valores del sonic/ control de movimiento
	P4: process(CLOCK, RESET)
	begin
		 if RESET = '0' then
			  X_CENTRO <= -200; 
			  POSY <= 250;
			  JUMPING <= '0';
			  X_CENTROE <= 0;
			  DIREC <= '1';
			  BALA_ON <= '0';
			  CNT_DISP <= 0;
			  VIDAS <= 4;
			  COLECT <= 0;
			  VIDASONIC <= 1;
			  VELENEMY <= 3;
			  VIS_A1 <= '1';
			  VIS_A2 <= '1';
			  VIS_A3 <= '1';
			  ENDGAME <='0';
			  linea_actual<=0;

		 elsif VSINC'event and VSINC = '1' then
				if VIDASONIC<=0 or VIDAS<=0 then
					ENDGAME<='1';
				end if;
				if ENDGAME = '1' then
                -- Control de velocidad de la transición
                if CONT_END < 1 then
                    CONT_END <= CONT_END + 1;
                else
                    CONT_END <= 0;

                    -- Pinta un nuevo cuadro de negro
                    if linea_actual < 525 then
                        linea_actual <= linea_actual + 3;
							end if;
                end if;
            end if;
			  -- Movimiento del cuadrado
			  if SWF = '1' then
					X_CENTRO <= X_CENTRO + VELOCIDAD;
			  elsif SWB = '1' then
					X_CENTRO <= X_CENTRO - VELOCIDAD;
			  end if;

			  -- Movimiento del enemigo
			  if DIREC = '1' then
					X_CENTROE <= X_CENTROE + VELENEMY;
			  else
					X_CENTROE <= X_CENTROE - VELENEMY;
			  end if;

			  -- Salto y gravedad
			  if (JUMP = '1' and JUMPING = '0') then
					JUMPING <= '1';
					VELY <= JUMP_FORCE;
			  end if;

			  if JUMPING = '1' then
					LADO <= 10;
					POSY <= POSY + VELY;
					VELY <= VELY + GRAVEDAD;
					if POSY+27 > GROUND_LEVEL then
						 POSY <= GROUND_LEVEL-27;
						 JUMPING <= '0';
						 LADO <= 20;
						 VELY <= 0;
					end if;
			  else
			--si no esta en el piso pero no tiene velocidad, se reactiva la caida
					if POSY+27<GROUND_LEVEL and VELY=0 then
						JUMPING<='1';
					end if;
				end if;
				
				--se cambia la pocision del piso si se encuentra en el area de la plataforma
				--nota: no poner otra plataforma encima, no la va a detectar
				if (POSY <= (POSY2 + ALTURA2)) and 
					(X_CENTRO+460 >= X_CENTRO2 and (X_CENTRO+450) <= (X_CENTRO2 + LADO2)) then 
					GROUND_LEVEL<=POSY2+17-ALTURA2;
				
				elsif (POSY <= (POSYP2 + ALTURAP2)) and 
					(X_CENTRO+460 >= X_CENTROP2 and (X_CENTRO+450) <= (X_CENTROP2 + LADOP2)) then 
					GROUND_LEVEL<=POSYP2+17-ALTURAP2;
				else
				--el piso esta hecho de piso
					GROUND_LEVEL<=PISO;
				end if;
				
				--DETECCION DE ENEMIGO
				if VIDAS>0 and VIDASONIC>0 and 
						(POSY <= (POSYE + ALTURAE) and (POSY+LADO)>=POSYE) and 
						(X_CENTRO+460 >= ((X_CENTROE+444)-LADOE) and (X_CENTRO+450) <= ((X_CENTROE+444) + LADOE)) then -- Está en la misma Y

						 -- Si el jugador lo toca caminando, pierde
						 if JUMPING = '0' then
							  VIDASONIC<=VIDASONIC-1;

						 -- Si el jugador cae sobre él, lo elimina
						 elsif JUMPING = '1' and (POSY + VELY >= POSYE) then
							  VIDAS<=VIDAS-1; -- El enemigo desaparece
							  VELENEMY<=VELENEMY+2;
							  INTERVALO<=INTERVALO-10;
							  
							  VELY <= JUMP_FORCE; -- Rebote al derrotarlo
						 end if;
				 end if;

			  -- Disparar balas
			  if CNT_DISP < INTERVALO then
					CNT_DISP <= CNT_DISP + 1;
			  else
					if BALA_ON = '0' then
						 BALA_ON <= '1';
						 X_CBALA <= X_CENTROE+444;
						 POSYBALA <= POSYE + 10;
					end if;
					CNT_DISP <= 0;
			  end if;

			  -- Detección de balas
			  if BALA_ON = '1' and VIDAS > 0 then
					POSYBALA <= POSYBALA + GRAVBALA;
					if (X_CBALA + 10 > X_CENTRO+450 and X_CBALA < (X_CENTRO+450) + LADO) and 
						(POSYBALA + 10 > POSY and POSYBALA < POSY + LADO) then
						 if VIDASONIC >= 0 then
							  VIDASONIC <= VIDASONIC - 1;
						 end if;
						 BALA_ON <= '0';
					elsif POSYBALA >= PISO + 20 then
						 BALA_ON <= '0';
					end if;
			  end if;
			  
			  --COLISION DE LOS ARO1
				if VIS_A1='1' and VIDASONIC>0 and 
               (POSY <= (Y_ARO1 + RADARO1) and (POSY+LADO)>=Y_ARO1) and 
					((X_CENTRO+450)+LADO >= X_ARO1 and (X_CENTRO+450) <= (X_ARO1 + RADARO1)) then
					VIS_A1<='0';
					COLECT<=COLECT+1;
				end if;
				
				--COLISION DE LOS ARO2
				if VIS_A2='1' and VIDASONIC>0 and 
               (POSY <= (Y_ARO2 + RADARO2) and (POSY+LADO)>=Y_ARO2) and 
					((X_CENTRO+450)+LADO >= X_ARO2 and (X_CENTRO+450) <= (X_ARO2 + RADARO2)) then
					VIS_A2<='0';
					COLECT<=COLECT+1;
				end if;
				
				--COLISION DE LOS ARO3
				if VIS_A3='1' and VIDASONIC>0 and 
               (POSY <= (Y_ARO3 + RADARO3) and (POSY+LADO)>=Y_ARO3) and 
					((X_CENTRO+450)+LADO >= X_ARO3 and (X_CENTRO+450) <= (X_ARO3 + RADARO3)) then
					VIS_A3<='0';
					COLECT<=COLECT+1;
				end if;
				
				if COLECT>=3 then
					VIDASONIC<=VIDASONIC+1;
					COLECT<=0;
				end if;

			  -- Evitar que el PER salga de los límites
			  if X_CENTRO+450 <= 200 then
					X_CENTRO <= -249;
			  elsif X_CENTRO+450 >= 750 then
					X_CENTRO <= 299;
			  end if;

			  -- Evitar que el enemigo salga de los límites
			  if X_CENTROE + 444 <= 200 then
					DIREC <= '1';
			  elsif X_CENTROE + 444 >= 700 then
					DIREC <= '0';
			  end if;
		 end if;
	end process;
	
	-- Proceso para Pintar el sonic
P5: process(XCOUNT, YCOUNT, EDO) is
begin
    -- **Por defecto, todo es negro**
    R_CUADRADO <= "0000";
    G_CUADRADO <= "0000";
    B_CUADRADO <= "0000";
	 if EDO = VIS and VIDASONIC>0 and JUMPING='1' and ENDGAME='0' then
				-- definicion del circulo 
								if ((unsigned(XCOUNT) >= to_unsigned(445, 10) + to_unsigned(X_CENTRO, 10)
										  AND unsigned(XCOUNT) < to_unsigned(455, 10)+ to_unsigned(X_CENTRO, 10)
										  AND unsigned(YCOUNT) >= to_unsigned(POSY, 10) 
										  AND unsigned(YCOUNT) < to_unsigned(POSY+2, 10)) -- Línea superior

									or (unsigned(XCOUNT) >= to_unsigned(443, 10)+ to_unsigned(X_CENTRO, 10) 
										  AND unsigned(XCOUNT) < to_unsigned(457, 10)+ to_unsigned(X_CENTRO, 10)
										  AND unsigned(YCOUNT) >= to_unsigned(POSY+2, 10) 
										  AND unsigned(YCOUNT) < to_unsigned(POSY+4, 10)) -- Segunda fila

									or (unsigned(XCOUNT) >= to_unsigned(442, 10)+ to_unsigned(X_CENTRO, 10) 
										  AND unsigned(XCOUNT) < to_unsigned(458, 10)+ to_unsigned(X_CENTRO, 10)
										  AND unsigned(YCOUNT) >= to_unsigned(POSY+4, 10) 
										  AND unsigned(YCOUNT) < to_unsigned(POSY+7, 10)) -- Parte media superior

									or (unsigned(XCOUNT) >= to_unsigned(441, 10) + to_unsigned(X_CENTRO, 10)
										  AND unsigned(XCOUNT) < to_unsigned(459, 10) + to_unsigned(X_CENTRO, 10)
										  AND unsigned(YCOUNT) >= to_unsigned(POSY+7, 10) 
										  AND unsigned(YCOUNT) < to_unsigned(POSY+11, 10)) -- Parte media inferior

									or (unsigned(XCOUNT) >= to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
										  AND unsigned(XCOUNT) < to_unsigned(458, 10) + to_unsigned(X_CENTRO, 10)
										  AND unsigned(YCOUNT) >= to_unsigned(POSY+11, 10) 
										  AND unsigned(YCOUNT) < to_unsigned(POSY+14, 10)) -- Segunda fila desde abajo

									or (unsigned(XCOUNT) >= to_unsigned(443, 10)+ to_unsigned(X_CENTRO, 10) 
										  AND unsigned(XCOUNT) < to_unsigned(457, 10)+ to_unsigned(X_CENTRO, 10)
										  AND unsigned(YCOUNT) >= to_unsigned(POSY+14, 10) 
										  AND unsigned(YCOUNT) < to_unsigned(POSY+16, 10)) -- Tercera fila desde abajo

									or (unsigned(XCOUNT) >= to_unsigned(445, 10) + to_unsigned(X_CENTRO, 10)
										  AND unsigned(XCOUNT) < to_unsigned(455, 10)+ to_unsigned(X_CENTRO, 10)
										  AND unsigned(YCOUNT) >= to_unsigned(POSY+16, 10) 
										  AND unsigned(YCOUNT) < to_unsigned(POSY+18, 10))) -- Línea inferior

								then
									if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
									elsif PER = '0' then 
										  R_CUADRADO <= "0000";
										  G_CUADRADO <= "0000";
										  B_CUADRADO <= "1000";
										else
											  R_CUADRADO <= "1000";
											  G_CUADRADO <= "0000";
											  B_CUADRADO <= "0000";
										end if;
							end if;

    elsif EDO = VIS and VIDASONIC>0 and JUMPING='0' and ENDGAME='0' then
							---------------------------------------------------------------------------------------------------------------------------
												-- Inicia Sonic
				---------------------------------------------------------------------------------------------------------------------------
						
							if	((unsigned(XCOUNT) > to_unsigned(440, 10) + to_unsigned(X_CENTRO, 10) -- linea principal de arriba 
							  AND unsigned(XCOUNT) < to_unsigned(452, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) > to_unsigned(POSY+2, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+4, 10)) 
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(452, 10) + to_unsigned(X_CENTRO, 10)-- linea corta siguiente de arriba
							  AND unsigned(XCOUNT) < to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+4, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+5, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10) -- dos pixeles despues de linea corta
							  AND unsigned(XCOUNT) < to_unsigned(457, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) > to_unsigned(POSY+2, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(POSY+4, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)-- 3 pixeles hacia abajo
							  AND unsigned(XCOUNT) < to_unsigned(457, 10)  + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+4, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+7, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(457, 10) + to_unsigned(X_CENTRO, 10)-- 3 ixelees hacia abajo despues del anterior
							  AND unsigned(XCOUNT) < to_unsigned(458, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+7, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+10, 10))
							  
							  -- INICIA CRUZZZZZZZZZZZZZZZZ
							  or (unsigned(XCOUNT) >=  to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10) --linea hacia abajo
							  AND unsigned(XCOUNT) < to_unsigned(457, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+10, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+15, 10))  
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10) --PUNTOSS izq
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+12, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+13, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(457, 10) + to_unsigned(X_CENTRO, 10)--PUNTOSS
							  AND unsigned(XCOUNT) < to_unsigned(458, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+12, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+13, 10))
							  -- TERMINA CRUZZZZZZZZZZZZZZZZZZZZZ
							 
							  or (unsigned(XCOUNT) >=  to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)-- dos pixeles abajo
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+15, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+17, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(448, 10) + to_unsigned(X_CENTRO, 10) -- 7 pixeles izq
							  AND unsigned(XCOUNT) < to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+16, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+17, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(440, 10) + to_unsigned(X_CENTRO, 10)-- 9 pixeles izq
							  AND unsigned(XCOUNT) < to_unsigned(448, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+15, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+16, 10))
				
				---------------------------------------------------------------------------------------------------------------------------
												-- Inicia Parte superior izquierda
				---------------------------------------------------------------------------------------------------------------------------

							  or (unsigned(XCOUNT) >=  to_unsigned(440, 10) + to_unsigned(X_CENTRO, 10)-- 1 pixeles esq sup izq 
							  AND unsigned(XCOUNT) < to_unsigned(441, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+4, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+5, 10))
							  
							  -- escalera abajo derecha
							  or (unsigned(XCOUNT) >=  to_unsigned(441, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+5, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+6, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+6, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+7, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(444, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+7, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+8, 10))
							  
							  	-- escalera abajo izq 3 pixeles
								
							  or (unsigned(XCOUNT) >=  to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+8, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+9, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(441, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+9, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+10, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(440, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(441, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+10, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+11, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(439, 10) + to_unsigned(X_CENTRO, 10) -- LINEA QUE SIGUE HACIA IZQ
							  AND unsigned(XCOUNT) < to_unsigned(445, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+11, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+12, 10))
							  
							  --ESCLAERA HACIA ABAJO IZQ 3 PIX
							  or (unsigned(XCOUNT) >=  to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(444, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+12, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+13, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+13, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+14, 10)) 
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(441, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+14, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+15, 10))) --hasta aqui todo biennnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
							  
		
							  then
							  
							  R_CUADRADO <= "0001"; 
							  G_CUADRADO <= "0001";
							  B_CUADRADO <= "0001";
				
		
							 
							
						--cuadrado 5 x 7 pixeles AZUULLL
					
						elsif  
							  (unsigned(XCOUNT) >=  to_unsigned(444, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(451, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+4, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+9, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
								
								

						elsif   --cuadrado 2*4 pix AZULLL
							  (unsigned(XCOUNT) >=  to_unsigned(451, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(452, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+4, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+8, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
						
						-- OJOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
						
						
						elsif   --ojo 2*6 pix
							  (unsigned(XCOUNT) >=  to_unsigned(451, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+8, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+14, 10))
							  then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1111";
							  B_CUADRADO <= "1111";
						
							elsif   --ojo punto derecha antes de linea negra
							  (unsigned(XCOUNT) >=  to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+9, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+10, 10))
							  then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1111";
							  B_CUADRADO <= "1111";
							  
							  
							  elsif   --linea negra hacia abajo
							  (unsigned(XCOUNT) >=  to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+10, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+13, 10))
							  then 
							  R_CUADRADO <= "0001";
							  G_CUADRADO <= "0001";
							  B_CUADRADO <= "0001";
							  
							  elsif   --pixel abajo de linea negra, blanco  
							  (unsigned(XCOUNT) >=  to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+13, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+14, 10))
							  then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1111";
							  B_CUADRADO <= "1111";
							  
							  
							  elsif   --pixel derecha de linea negra, blanco  
							  (unsigned(XCOUNT) >=  to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+12, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+13, 10))
							  then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1111";
							  B_CUADRADO <= "1111";
							  
							  elsif   -- 2 pixeles blanco, pegado a cruz  
							  (unsigned(XCOUNT) >=  to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+10, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+12, 10))
							  then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1111";
							  B_CUADRADO <= "1111";
							  
							  elsif   -- 3 pixeles blanco, izq de cuadrado blanco  
							  (unsigned(XCOUNT) >=  to_unsigned(450, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(451, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+9, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+12, 10))
							  then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1111";
							  B_CUADRADO <= "1111";
						
						--  TERMINA OJOOOOO0000000000000000oooooooo
						
						
						elsif   -- REctangulo 2 de alto AZUL 
							  (unsigned(XCOUNT) >=  to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(450, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+9, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+11, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
							  
						elsif   -- un PIXEL cresta ABAJO AZUL  
							  (unsigned(XCOUNT) >=  to_unsigned(441, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+10, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+11, 10))
							  then 
							  if PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "1000";
								  G_CUADRADO <= "0000";
								  B_CUADRADO <= "0000";
								end if;
						
						elsif   -- un PIXEL cresta medio AZUL  
							  (unsigned(XCOUNT) >=  to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(444, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+8, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+9, 10))
							  then 
							  
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
							  
							  
							  
							  -- escalera invertida arriba
							  
						elsif     
							  (unsigned(XCOUNT) >=  to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(444, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+4, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+7, 10))
							  then 
							  if PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "1000";
								  G_CUADRADO <= "0000";
								  B_CUADRADO <= "0000";
								end if;
							  
						elsif     
							  (unsigned(XCOUNT) >=  to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+4, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+6, 10))
							  then 
							  if PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "1000";
								  G_CUADRADO <= "0000";
								  B_CUADRADO <= "0000";
								end if;
							  
						elsif     
							  (unsigned(XCOUNT) >=  to_unsigned(441, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+4, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+5, 10))
							  then 
							  if PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "1000";
								  G_CUADRADO <= "0000";
								  B_CUADRADO <= "0000";
								end if;
						-- termina escalera invertida arriba
						
						
						-- 4*3 PIXELES AZULES ARRIBA DEL OJO
						elsif     
							  (unsigned(XCOUNT) >=  to_unsigned(452, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+5, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+8, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
							  
						-- pixel esquina superior derecha
						elsif     
							  (unsigned(XCOUNT) >=  to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+4, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+5, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
							  
						-- 3 pixeles hacia abajo limite derecho
						elsif 
								(unsigned(XCOUNT) >=  to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(457, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+7, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+10, 10)) then 
							  if PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "1000";
								  G_CUADRADO <= "0000";
								  B_CUADRADO <= "0000";
								end if;
							  
						-- 2*2 pixeles azul
						 elsif   
							  (unsigned(XCOUNT) >=  to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+8, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+10, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
--							  
						-- PIXEL IZQ DE 2*2 
						 elsif   
							  (unsigned(XCOUNT) >=  to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+8, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+9, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
							  
						
						-- 2 pixeles azul hacia abajo al lado de linea negra
						 elsif   
							 (unsigned(XCOUNT) >=  to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10)
							 AND unsigned(XCOUNT) < to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)
							 AND unsigned(YCOUNT) >= to_unsigned(POSY + 10, 10) 
							 AND unsigned(YCOUNT) < to_unsigned(POSY + 12, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
							  
							  
							  
							  
							  
		----------------------------------------------------------------------------
		-- TERMINA LADO DERecho
		-----------------------------------------------------------------------------
						
						-- rECtangulo de 2 * 5
						elsif   
							 (unsigned(XCOUNT) >=  to_unsigned(445, 10) + to_unsigned(X_CENTRO, 10)
							 AND unsigned(XCOUNT) < to_unsigned(450, 10) + to_unsigned(X_CENTRO, 10)
							 AND unsigned(YCOUNT) >= to_unsigned(POSY + 11, 10) 
							 AND unsigned(YCOUNT) < to_unsigned(POSY + 13, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
							  
						elsif   -- pixel izq de rectangulo 2*5
							  (unsigned(XCOUNT) >=  to_unsigned(444, 10) + to_unsigned(X_CENTRO, 10)
								AND unsigned(XCOUNT) < to_unsigned(445, 10) + to_unsigned(X_CENTRO, 10)
								AND unsigned(YCOUNT) >= to_unsigned(POSY + 12, 10) 
								AND unsigned(YCOUNT) < to_unsigned(POSY + 13, 10))
							  then 
							  if PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "1000";
								  G_CUADRADO <= "0000";
								  B_CUADRADO <= "0000";
								end if;
							  
						elsif   -- pixel der de rectangulo 2*5
							 (unsigned(XCOUNT) >=  to_unsigned(450, 10) + to_unsigned(X_CENTRO, 10)
							 AND unsigned(XCOUNT) < to_unsigned(451, 10) + to_unsigned(X_CENTRO, 10)
							 AND unsigned(YCOUNT) >= to_unsigned(POSY + 12, 10) 
							 AND unsigned(YCOUNT) < to_unsigned(POSY + 13, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
							  
							  
							  
						elsif   -- rectangulo 2*5 abajo
							 (unsigned(XCOUNT) >=  to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							 AND unsigned(XCOUNT) < to_unsigned(448, 10) + to_unsigned(X_CENTRO, 10)
							 AND unsigned(YCOUNT) >= to_unsigned(POSY+13, 10) 
							 AND unsigned(YCOUNT) < to_unsigned(POSY+15, 10))

							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
							  
						elsif  -- pixel que completa a izq
							 (unsigned(XCOUNT) >=  to_unsigned(442, 10) + to_unsigned(X_CENTRO, 10)
							 AND unsigned(XCOUNT) < to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							 AND unsigned(YCOUNT) >= to_unsigned(POSY + 14, 10) 
							 AND unsigned(YCOUNT) < to_unsigned(POSY + 15, 10))

							  then 
							  if PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "1000";
								  G_CUADRADO <= "0000";
								  B_CUADRADO <= "0000";
								end if;
							  
							  
							  
							  
							  
							  
							  
					-- EMPIEZA OOOOOOCCCCCIIIIIIICCCCCOOOOOOOOOOOOOOOOOOOOOOOOO
					
					
					elsif  -- 3*2 píxeles
						 (unsigned(XCOUNT) >=  to_unsigned(448, 10) + to_unsigned(X_CENTRO, 10)
						 AND unsigned(XCOUNT) < to_unsigned(451, 10) + to_unsigned(X_CENTRO, 10)
						 AND unsigned(YCOUNT) >= to_unsigned(POSY + 13, 10) 
						 AND unsigned(YCOUNT) < to_unsigned(POSY + 15, 10))

							  then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1101";
							  B_CUADRADO <= "1010";
							  
					elsif  -- linea ocico hasta abajo 
							  (unsigned(XCOUNT) >=  to_unsigned(449, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+15, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+16, 10))
							  then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1101";
							  B_CUADRADO <= "1010";
						
						
						elsif  -- linea ocico arriba de la de abajo 
							  (unsigned(XCOUNT) >=  to_unsigned(451, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+14, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+15, 10))
							  then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1101";
							  B_CUADRADO <= "1010";
						
						
						elsif  -- linea que termina ocico
							  (unsigned(XCOUNT) >=  to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+13, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+14, 10))
							  then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1101";
							  B_CUADRADO <= "1010";
							  
						--POSY0=266	  
							  
							  
							  --CUERPOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
							 
					--  -- cuerpo cuadrado
 
							  
						
						elsif 
							  ((unsigned(XCOUNT) >=  to_unsigned(445, 10) + to_unsigned(X_CENTRO, 10)-- borde izq cuerpo
							  AND unsigned(XCOUNT) < to_unsigned(446, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+16, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+24, 10))
							  or 
							
							  (unsigned(XCOUNT) >=  to_unsigned(445, 10) + to_unsigned(X_CENTRO, 10)-- linea negra hasta abajo del cuerpo
							  AND unsigned(XCOUNT) < to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+23, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+24, 10)))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)  --borde derecho del cuerpo
							  AND unsigned(XCOUNT) < to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+17, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+24, 10))
							  then 
							  R_CUADRADO <= "0001";
							  G_CUADRADO <= "0001";
							  B_CUADRADO <= "0001";
							  
		
						
						elsif  -- pedazo azul cuerpo izq
							  (unsigned(XCOUNT) >=  to_unsigned(446, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(448, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+16, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+24, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
							  elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
						
						elsif  -- panza
							  (unsigned(XCOUNT) >=  to_unsigned(448, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(450, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+19, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+22, 10))
							  then 
							  if PER = '0' then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1101";
							  B_CUADRADO <= "1010";
							  else
								  R_CUADRADO <= "1111";
								  G_CUADRADO <= "1111";
								  B_CUADRADO <= "1111";
								end if;
						
						elsif 
							  (unsigned(XCOUNT) >=  to_unsigned(448, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+17, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+19, 10))
							 
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
						
						elsif 
						
							  (unsigned(XCOUNT) >=  to_unsigned(448, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+22, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+23, 10))
							  then 
							  if VIDASONIC=2 then  
									R_CUADRADO <= "1111";
									G_CUADRADO <= "1101";
									B_CUADRADO <= "1010";
								elsif PER = '0' then 
							  R_CUADRADO <= "0000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "1000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
							  
							  
						elsif --panza
						
							  (unsigned(XCOUNT) >=  to_unsigned(450, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+19, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+22, 10))
							  then 
							  if PER = '0' then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1101";
							  B_CUADRADO <= "1010";
							  else
								  R_CUADRADO <= "1111";
								  G_CUADRADO <= "1111";
								  B_CUADRADO <= "1111";
								end if;
						 
						 
						 
						 
						 
						 elsif --zapato izq 
							  ((unsigned(XCOUNT) >=  to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)--dos pixeles al lado del cuerpo
							  AND unsigned(XCOUNT) < to_unsigned(445, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+23, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+24, 10))
							  or 
							  (unsigned(XCOUNT) >=  to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)-- tres pixeles hacia abajo 
							  AND unsigned(XCOUNT) < to_unsigned(444, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+23, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+27, 10))
							  or 
							  (unsigned(XCOUNT) >=  to_unsigned(443, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(449, 10) + to_unsigned(X_CENTRO, 10)--linea abajo del zapato
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+27, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+28, 10))
							  or 
							  (unsigned(XCOUNT) >=  to_unsigned(449, 10) + to_unsigned(X_CENTRO, 10)-- linea que cierra zapato izq
							  AND unsigned(XCOUNT) < to_unsigned(450, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+24, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+28, 10))						
							  or 
							  (unsigned(XCOUNT) >=  to_unsigned(450, 10) + to_unsigned(X_CENTRO, 10) -- suela zapato derecho
							  AND unsigned(XCOUNT) < to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+27, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+28, 10))  
							  or 
							  (unsigned(XCOUNT) >=  to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)  -- linea extremo derecho sonic
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+23, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+28, 10))
							  
							  or 
							  (unsigned(XCOUNT) >=  to_unsigned(454, 10) + to_unsigned(X_CENTRO, 10) -- pixel que cierra zapato derecho 
							  AND unsigned(XCOUNT) < to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+23, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+24, 10)))
							  
							  then 
							  R_CUADRADO <= "0001";
							  G_CUADRADO <= "0001";
							  B_CUADRADO <= "0001";
						 
						 elsif   -- blanco del zapato
							  ((unsigned(XCOUNT) >=  to_unsigned(446, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(447, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+24, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+27, 10))
							  or 
							
							  (unsigned(XCOUNT) >=  to_unsigned(452, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+24, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+27, 10)))
							  then 
							  if PER = '0' then 
							  R_CUADRADO <= "1111";
							  G_CUADRADO <= "1111";
							  B_CUADRADO <= "1111";
							  else
								  R_CUADRADO <= "1000";
								  G_CUADRADO <= "0000";
								  B_CUADRADO <= "0000";
								end if;
						 
						 elsif   -- rojo del zapato
							  ((unsigned(XCOUNT) >=  to_unsigned(444, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(446, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+24, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+27, 10))
							  or 
							
							  (unsigned(XCOUNT) >=  to_unsigned(450, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(452, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+24, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+27, 10))
							  or 
							
							  (unsigned(XCOUNT) >=  to_unsigned(447, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(449, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+24, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+27, 10))
							  
							  or 
							
							  (unsigned(XCOUNT) >=  to_unsigned(453, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(XCOUNT) < to_unsigned(455, 10) + to_unsigned(X_CENTRO, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(POSY+24, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(POSY+27, 10)))
							  then 
							  if PER = '0' then 
							  R_CUADRADO <= "1000";
							  G_CUADRADO <= "0000";
							  B_CUADRADO <= "0000";
							  else
								  R_CUADRADO <= "0001";
								  G_CUADRADO <= "0001";
								  B_CUADRADO <= "0001";
								end if;
				end if;
			end if;

end process;

	--pintar PRIMER PLATAFORMA
	P6: process(XCOUNT, YCOUNT, EDO) is
	begin
		if EDO = VIS and ENDGAME='0'then
			if (to_integer(unsigned(YCOUNT)) >= POSY2 and to_integer(unsigned(YCOUNT)) <= (POSY2 + ALTURA2)) and 
			   (to_integer(unsigned(XCOUNT)) >= X_CENTRO2 and to_integer(unsigned(XCOUNT)) <= (X_CENTRO2 + LADO2)) then 
				R_CUADRADO2 <= "0000"; -- VERDE
				G_CUADRADO2 <= "1111";
				B_CUADRADO2 <= "0000";
			else
				R_CUADRADO2 <= "0000";
				G_CUADRADO2 <= "0000";
				B_CUADRADO2 <= "0000";
			end if;
		else
			R_CUADRADO2 <= "0000";
			G_CUADRADO2 <= "0000";
			B_CUADRADO2 <= "0000";
		end if;
	end process;
	--PINTAR SEGUNDA PLATAFORMA
	P7: process(XCOUNT, YCOUNT, EDO) is
	begin
		if EDO = VIS and ENDGAME='0'then
			if (to_integer(unsigned(YCOUNT)) >= POSYP2 and to_integer(unsigned(YCOUNT)) <= (POSYP2 + ALTURAP2)) and 
			   (to_integer(unsigned(XCOUNT)) >= X_CENTROP2 and to_integer(unsigned(XCOUNT)) <= (X_CENTROP2 + LADOP2)) then 
				R_PLAT2 <= "0000"; -- VERDE
				G_PLAT2 <= "1111";
				B_PLAT2 <= "0000";
			else
				R_PLAT2 <= "0000";
				G_PLAT2 <= "0000";
				B_PLAT2 <= "0000";
			end if;
		else
			R_PLAT2 <= "0000";
			G_PLAT2 <= "0000";
			B_PLAT2 <= "0000";
		end if;
	end process;
	--PINTAR ENEMIGO
	P8: process(XCOUNT, YCOUNT, EDO) is
	begin
		if EDO = VIS and VIDAS>0 and ENDGAME='0'then
			--				---------------------------------------------------------------------------------------------------------------------------
--												-- Inicia Eggman
--				---------------------------------------------------------------------------------------------------------------------------
							
							if	((unsigned(XCOUNT) > to_unsigned(440, 10) + to_unsigned(X_CENTROE, 10) -- linea principal de arriba 
							  AND unsigned(XCOUNT) < to_unsigned(449, 10) + to_unsigned(X_CENTROE, 10) 
							  AND unsigned(YCOUNT) > to_unsigned(100, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(103, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(436, 10) + to_unsigned(X_CENTROE, 10) -- linea corta nivel dos izquierda
							  AND unsigned(XCOUNT) < to_unsigned(441, 10) + to_unsigned(X_CENTROE, 10) 
							  AND unsigned(YCOUNT) > to_unsigned(102, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(105, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(434, 10) + to_unsigned(X_CENTROE, 10)-- pixel nivel 3 izquieda
							  AND unsigned(XCOUNT) < to_unsigned(436, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(104, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(107, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(432, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 4 izquieda
							  AND unsigned(XCOUNT) < to_unsigned(434, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(105, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(108, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(422, 10) + to_unsigned(X_CENTROE, 10) -- linea nivel 4 izquieda
							  AND unsigned(XCOUNT) < to_unsigned(430, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(105, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(108, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(430, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 5 izquieda cerca de los ojos
							  AND unsigned(XCOUNT) < to_unsigned(432, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(106, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(109, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(420, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 5 izquieda bigote
							  AND unsigned(XCOUNT) < to_unsigned(422, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(106, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(109, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(422, 10) + to_unsigned(X_CENTROE, 10) -- linea nivel 6 izquieda 
							  AND unsigned(XCOUNT) < to_unsigned(426, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(108, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(111, 10))
							  
							  or (unsigned(XCOUNT) >= to_unsigned(420, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 7 izquieda bigote
							  AND unsigned(XCOUNT) < to_unsigned(422, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(110, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(113, 10)) 

							  
							  or (unsigned(XCOUNT) >=  to_unsigned(422, 10) + to_unsigned(X_CENTROE, 10)-- linea nivel 8 izquieda 
							  AND unsigned(XCOUNT) < to_unsigned(434, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(112, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(115, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(429, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 9 izquieda 
							  AND unsigned(XCOUNT) < to_unsigned(431, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(114, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(117, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(427, 10) + to_unsigned(X_CENTROE, 10) -- 2 pixeles nivel 10 y 11 izquieda 
							  AND unsigned(XCOUNT) < to_unsigned(429, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(116, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(121, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(425, 10) + to_unsigned(X_CENTROE, 10) -- 3 pixeles nivel 12, 13 y 14 izquieda 
							  AND unsigned(XCOUNT) < to_unsigned(427, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(120, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(127, 10))

				---------------------------------------------------------------------------------------------------------------------------
												-- Contorno derecho
				---------------------------------------------------------------------------------------------------------------------------

							  or (unsigned(XCOUNT) >=  to_unsigned(449, 10) + to_unsigned(X_CENTROE, 10) -- linea corta nivel dos derecha
							  AND unsigned(XCOUNT) < to_unsigned(454, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(102, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(105, 10))

							  or (unsigned(XCOUNT) >=  to_unsigned(454, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 3 derecha
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTROE, 10) 
							  AND unsigned(YCOUNT) > to_unsigned(104, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(107, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(456, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 4 derecha
							  AND unsigned(XCOUNT) < to_unsigned(458, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(105, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(108, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(460, 10) + to_unsigned(X_CENTROE, 10)-- linea nivel 4 derecha
							  AND unsigned(XCOUNT) < to_unsigned(468, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(105, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(108, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(458, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 5 derecha cerca de los ojos
							  AND unsigned(XCOUNT) < to_unsigned(460, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(106, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(109, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(468, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 5 derecha bigote
							  AND unsigned(XCOUNT) < to_unsigned(470, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(106, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(109, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(465, 10) + to_unsigned(X_CENTROE, 10) -- linea nivel 6 derecha
							  AND unsigned(XCOUNT) < to_unsigned(468, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(108, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(111, 10))
							  
							  or (unsigned(XCOUNT) >= to_unsigned(468, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 7 derecha bigote
							  AND unsigned(XCOUNT) < to_unsigned(470, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(110, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(113, 10)) 

							  
							  or (unsigned(XCOUNT) >=  to_unsigned(456, 10) + to_unsigned(X_CENTROE, 10) -- linea nivel 8 derecha 
							  AND unsigned(XCOUNT) < to_unsigned(468, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(112, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(115, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(460, 10) + to_unsigned(X_CENTROE, 10) -- pixel nivel 9 derecha
							  AND unsigned(XCOUNT) < to_unsigned(462, 10) + to_unsigned(X_CENTROE, 10) 
							  AND unsigned(YCOUNT) > to_unsigned(114, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(117, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(462, 10) + to_unsigned(X_CENTROE, 10) -- 2 pixeles nivel 10 y 11 derecha 
							  AND unsigned(XCOUNT) < to_unsigned(464, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(116, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(121, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(464, 10) + to_unsigned(X_CENTROE, 10) -- 3 pixeles nivel 12, 13 y 14 derecha
							  AND unsigned(XCOUNT) < to_unsigned(466, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(120, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(127, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(439, 10) + to_unsigned(X_CENTROE, 10)-- cara arriba 
							  AND unsigned(XCOUNT) < to_unsigned(451, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(106, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(109, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(439, 10) + to_unsigned(X_CENTROE, 10) -- cara abajo izquierda
							  AND unsigned(XCOUNT) < to_unsigned(443, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(108, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(111, 10))
							  
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(447, 10) + to_unsigned(X_CENTROE, 10) -- cara abajo derecha
							  AND unsigned(XCOUNT) < to_unsigned(451, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(108, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(111, 10))
							  )
							  
							  then
							  
							  R_ENEMY <= "0001"; 
							  G_ENEMY <= "0001";
							  B_ENEMY <= "0001";
							  
				---------------------------------------------------------------------------------------------------------------------------
							-- Dibujador del tono marron claro para la piel
				---------------------------------------------------------------------------------------------------------------------------
							  
							elsif ((unsigned(XCOUNT) > to_unsigned(440, 10) + to_unsigned(X_CENTROE, 10) -- 8x2 piel parte de enmedio
							  AND unsigned(XCOUNT) < to_unsigned(449, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(102, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(105, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(436, 10) + to_unsigned(X_CENTROE, 10)-- 16x2 piel parte de enmedio
							  AND unsigned(XCOUNT) < to_unsigned(455, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(104, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(107, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(432, 10) + to_unsigned(X_CENTROE, 10) -- 4x4 piel izquierda
							  AND unsigned(XCOUNT) < to_unsigned(439, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(106, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(111, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(451, 10) + to_unsigned(X_CENTROE, 10) -- 4x4 piel derecha
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(106, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(111, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(436, 10) + to_unsigned(X_CENTROE, 10) -- 6x2 piel izquierda
							  AND unsigned(XCOUNT) < to_unsigned(443, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(110, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(113, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(447, 10) + to_unsigned(X_CENTROE, 10) -- 6x2 piel derecha
							  AND unsigned(XCOUNT) < to_unsigned(454, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(110, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(113, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(443, 10) + to_unsigned(X_CENTROE, 10) -- 2x1 piel enmedio
							  AND unsigned(XCOUNT) < to_unsigned(447, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(108, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(111, 10))
							  

							  )
							  
							  then 
							  
							  R_ENEMY <= "1110"; --marron claro
							  G_ENEMY <= "1101";
							  B_ENEMY <= "1001";
							  
				---------------------------------------------------------------------------------------------------------------------------
							-- Nariz
				---------------------------------------------------------------------------------------------------------------------------
							  
							elsif ((unsigned(XCOUNT) >= to_unsigned(443, 10) + to_unsigned(X_CENTROE, 10)-- 2x1 nariz arriba
							  AND unsigned(XCOUNT) < to_unsigned(447, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(111, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(113, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(441, 10) + to_unsigned(X_CENTROE, 10)-- 6x1 nariz abajo
							  AND unsigned(XCOUNT) < to_unsigned(449, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(113, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(115, 10))
							  

							  )
							  
							  then 
							  
							  R_ENEMY <= "1111"; --Rosa
							  G_ENEMY <= "1010";
							  B_ENEMY <= "1011";
							  
				---------------------------------------------------------------------------------------------------------------------------
							-- Bigote
				---------------------------------------------------------------------------------------------------------------------------
							  
							--Lado izquierdo
							
							elsif ((unsigned(XCOUNT) >= to_unsigned(434, 10) + to_unsigned(X_CENTROE, 10)-- 2x1 bigote izquierda
							  AND unsigned(XCOUNT) < to_unsigned(441, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(113, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(115, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(426, 10) + to_unsigned(X_CENTROE, 10)-- 6x1 bigote izquierda
							  AND unsigned(XCOUNT) < to_unsigned(437, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(111, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(113, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(426, 10) + to_unsigned(X_CENTROE, 10)-- 6x2 bigote izquierda
							  AND unsigned(XCOUNT) < to_unsigned(434, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(109, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(111, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(422, 10) + to_unsigned(X_CENTROE, 10)-- 6x1 bigote izquierda
							  AND unsigned(XCOUNT) < to_unsigned(430, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(106, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(109, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(422, 10) + to_unsigned(X_CENTROE, 10) -- 6x2 bigote izquierda
							  AND unsigned(XCOUNT) < to_unsigned(426, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(111, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(113, 10))
							  
							--Lado derecho
							
							  or (unsigned(XCOUNT) >= to_unsigned(449, 10) + to_unsigned(X_CENTROE, 10) -- 2x1 bigote derecha
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(113, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(115, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(454, 10) + to_unsigned(X_CENTROE, 10)-- 6x1 bigote derecha
							  AND unsigned(XCOUNT) < to_unsigned(470, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(111, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(113, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(456, 10) + to_unsigned(X_CENTROE, 10)-- 1x2 bigote derecha
							  AND unsigned(XCOUNT) < to_unsigned(458, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(108, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(111, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(460, 10) + to_unsigned(X_CENTROE, 10) -- 6x1 bigote derecha
							  AND unsigned(XCOUNT) < to_unsigned(469, 10)  + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(107, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(109, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(458, 10) + to_unsigned(X_CENTROE, 10) -- 6x2 bigote derecha
							  AND unsigned(XCOUNT) < to_unsigned(465, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(109, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(111, 10))

							  )
							  
							  then 
							  
							  R_ENEMY <= "1001"; --marron fuerte
							  G_ENEMY <= "0101";
							  B_ENEMY <= "0011";
							
				---------------------------------------------------------------------------------------------------------------------------
							-- Nave
				---------------------------------------------------------------------------------------------------------------------------
							elsif ((unsigned(XCOUNT) >= to_unsigned(421, 10) + to_unsigned(X_CENTROE, 10) -- rectangulo nave
							  AND unsigned(XCOUNT) < to_unsigned(469, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(126, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(137, 10))
							  
							  )
							  then
							  R_ENEMY <= "0110";  --gris
							  G_ENEMY <= "0110";
							  B_ENEMY <= "0110";
							  
							--detalles negros
							  
							elsif ((unsigned(XCOUNT) >= to_unsigned(425, 10) + to_unsigned(X_CENTROE, 10)-- rectangulo negro nave 
							  AND unsigned(XCOUNT) < to_unsigned(469, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(136, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(140, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(429, 10) + to_unsigned(X_CENTROE, 10) -- rectangulo 2 negro nave 
							  AND unsigned(XCOUNT) < to_unsigned(465, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(139, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(143, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(461, 10) + to_unsigned(X_CENTROE, 10) -- linea vertical nave 
							  AND unsigned(XCOUNT) < to_unsigned(463, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(130, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(137, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(463, 10) + to_unsigned(X_CENTROE, 10) -- linea horizontal nave
							  AND unsigned(XCOUNT) < to_unsigned(469, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(128, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(131, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(421, 10) + to_unsigned(X_CENTROE, 10) -- pixel izquierda nave
							  AND unsigned(XCOUNT) < to_unsigned(423, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(128, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(131, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(426, 10) + to_unsigned(X_CENTROE, 10) -- pixel derecha nave
							  AND unsigned(XCOUNT) < to_unsigned(428, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) > to_unsigned(128, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(131, 10))
							  
							  )
							  then
							  R_ENEMY <= "0001"; --negro
							  G_ENEMY <= "0001";
							  B_ENEMY <= "0001";
							  
							--detalles amarillos
							  
							elsif ((unsigned(XCOUNT) >= to_unsigned(423, 10) + to_unsigned(X_CENTROE, 10)-- pixel amarillo nave izquierda
							  AND unsigned(XCOUNT) < to_unsigned(425, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(128, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(131, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(449, 10) + to_unsigned(X_CENTROE, 10) -- pixel amarillo nave derecha 
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(128, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(131, 10))
							  
--							  or (unsigned(XCOUNT) >=  to_unsigned(463, 10) -- cuadrado amarillo
--							  AND unsigned(XCOUNT) < to_unsigned(469, 10)
--							  AND unsigned(YCOUNT) > to_unsigned(130, 10)  
--							  AND unsigned(YCOUNT) < to_unsigned(137, 10))
							  
							  )
							  then
							  R_ENEMY <= "1111"; --amarillo
							  G_ENEMY <= "1011";
							  B_ENEMY <= "0010";
							  
				---------------------------------------------------------------------------------------------------------------------------
							-- Cuerpo
				---------------------------------------------------------------------------------------------------------------------------
							  
							elsif ((unsigned(XCOUNT) >= to_unsigned(427, 10) + to_unsigned(X_CENTROE, 10) -- 2x18 rectangulo rojo
							  AND unsigned(XCOUNT) < to_unsigned(464, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(121, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(127, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(441, 10) + to_unsigned(X_CENTROE, 10) -- 4x4 cuadrado rojo entre arreglo amarillos
							  AND unsigned(XCOUNT) < to_unsigned(449, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(115, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(121, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(430, 10) + to_unsigned(X_CENTROE, 10)-- 2x1 cuadrado rojo entre arreglo amarillos
							  AND unsigned(XCOUNT) < to_unsigned(434, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(115, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(121, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(428, 10) + to_unsigned(X_CENTROE, 10)  -- 1x1 cuadrado rojo entre arreglo amarillos
							  AND unsigned(XCOUNT) < to_unsigned(430, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(117, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(121, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(456, 10) + to_unsigned(X_CENTROE, 10)-- 2x1 cuadrado rojo entre arreglo amarillos
							  AND unsigned(XCOUNT) < to_unsigned(460, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(115, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(121, 10))
							  
							  	or (unsigned(XCOUNT) >=  to_unsigned(460, 10) + to_unsigned(X_CENTROE, 10) -- 1x1 cuadrado rojo entre arreglo amarillos
							  AND unsigned(XCOUNT) < to_unsigned(462, 10) + to_unsigned(X_CENTROE, 10) 
							  AND unsigned(YCOUNT) >= to_unsigned(117, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(121, 10))
							  

							  )
							  
							  then 
							  
							  R_ENEMY <= "1111"; --Rojo
							  G_ENEMY <= "0010";
							  B_ENEMY <= "0010";
							  
							--amarillo
							  
							elsif ((unsigned(XCOUNT) >= to_unsigned(434, 10) + to_unsigned(X_CENTROE, 10) -- cuadrado amarillo izquierda cuerpo
							  AND unsigned(XCOUNT) < to_unsigned(441, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(115, 10) 
							  AND unsigned(YCOUNT) < to_unsigned(121, 10))
							  
							  or (unsigned(XCOUNT) >=  to_unsigned(449, 10) + to_unsigned(X_CENTROE, 10) -- cuadrado amarillo derecha cuerpo 
							  AND unsigned(XCOUNT) < to_unsigned(456, 10) + to_unsigned(X_CENTROE, 10)
							  AND unsigned(YCOUNT) >= to_unsigned(115, 10)  
							  AND unsigned(YCOUNT) < to_unsigned(121, 10))
							  
							  )
							  then
							  R_ENEMY <= "1111"; --amarillo
							  G_ENEMY <= "1011";
							  B_ENEMY <= "0010";
			else
				R_ENEMY <= "0000";
				G_ENEMY <= "0000";
				B_ENEMY <= "0000";
			end if;
		else
			R_ENEMY <= "0000";
			G_ENEMY <= "0000";
			B_ENEMY <= "0000";
		end if;
	end process;
	--PINTA LAS BALAS
	P9: process(XCOUNT, YCOUNT, EDO)
	begin
		 if EDO = VIS and BALA_ON = '1' and VIDAS > 0 and ENDGAME='0' then
			  -- Definir límites de la bala
			  if (to_integer(unsigned(YCOUNT)) >= POSYBALA and 
					to_integer(unsigned(YCOUNT)) <= POSYBALA + 10) and
				  (to_integer(unsigned(XCOUNT)) >= X_CBALA and 
					to_integer(unsigned(XCOUNT)) <= X_CBALA + 10) then

					-- Detectar si está en el borde (primer o último píxel en X o Y)
					if (to_integer(unsigned(YCOUNT)) = POSYBALA or 
						 to_integer(unsigned(YCOUNT)) = POSYBALA + 10 or 
						 to_integer(unsigned(XCOUNT)) = X_CBALA or 
						 to_integer(unsigned(XCOUNT)) = X_CBALA + 10) then
						 
						 -- Borde rojo
						 R_BALA <= "1111"; -- Rojo máximo
						 G_BALA <= "0000";
						 B_BALA <= "0000";
					else
						 -- Interior amarillo
						 R_BALA <= "1111"; -- Rojo máximo
						 G_BALA <= "1111"; -- Verde máximo
						 B_BALA <= "0000"; -- Sin azul (rojo + verde = amarillo)
					end if;
			  else
					-- Fondo negro
					R_BALA <= "0000";
					G_BALA <= "0000";
					B_BALA <= "0000";
			  end if;
		 else
			  -- Fondo negro si la bala no está activa
			  R_BALA <= "0000";
			  G_BALA <= "0000";
			  B_BALA <= "0000";
		 end if;
	end process;
 
	--Aros del videojuego
	P10: process(XCOUNT, YCOUNT, EDO) is
	begin
		 -- Diferencia entre el pixel actual y el centro del aro
		 X_ARO1DIF <= to_integer(unsigned(XCOUNT)) - X_ARO1;
		 Y_ARO1DIF <= to_integer(unsigned(YCOUNT)) - Y_ARO1;
		 
		 -- Cálculo de distancia al cuadrado (para evitar raíces cuadradas)
		 DIST_A1 <= (X_ARO1DIF * X_ARO1DIF) + (Y_ARO1DIF * Y_ARO1DIF);

		if EDO = VIS and VIS_A1='1' and ENDGAME='0' then
			if (DIST_A1 >= (REXT - 1) * (REXT - 1) and DIST_A1 <= REXT * REXT) then
			  -- Contorno exterior negro
			  R_ARO1 <= "0001";
			  G_ARO1 <= "0001";
			  B_ARO1 <= "0001";
		 
			 elsif (DIST_A1 >= RINT * RINT and DIST_A1 < (REXT - 1) * (REXT - 1)) then
				  -- Relleno medio amarillo
				  R_ARO1 <= "1111";
				  G_ARO1 <= "1011";
				  B_ARO1 <= "0000";
			 
			 elsif (DIST_A1 < RINT * RINT) then
				  -- Círculo central negro
				  R_ARO1 <= "0000";
				  G_ARO1 <= "0000";
				  B_ARO1 <= "0000";
			else
				R_ARO1 <= "0000";
				G_ARO1 <= "0000";
				B_ARO1 <= "0000";
			end if;
		else
			R_ARO1 <= "0000";
			G_ARO1 <= "0000";
			B_ARO1 <= "0000";
		end if;
	end process;
	
	P11: process(XCOUNT, YCOUNT, EDO) is
	begin
		 -- Diferencia entre el pixel actual y el centro del aro
		 X_ARO2DIF <= to_integer(unsigned(XCOUNT)) - X_ARO2;
		 Y_ARO2DIF <= to_integer(unsigned(YCOUNT)) - Y_ARO2;
		 
		 -- Cálculo de distancia al cuadrado (para evitar raíces cuadradas)
		 DIST_A2 <= (X_ARO2DIF * X_ARO2DIF) + (Y_ARO2DIF * Y_ARO2DIF);

		if EDO = VIS and VIS_A2='1' and ENDGAME='0'then
			if (DIST_A2 >= (REXT - 1) * (REXT - 1) and DIST_A2 <= REXT * REXT) then
			  -- Contorno exterior negro
			  R_ARO2 <= "0001";
			  G_ARO2 <= "0001";
			  B_ARO2 <= "0001";
		 
			 elsif (DIST_A2 >= RINT * RINT and DIST_A2 < (REXT - 1) * (REXT - 1)) then
				  -- Relleno medio amarillo
				  R_ARO2 <= "1111";
				  G_ARO2 <= "1011";
				  B_ARO2 <= "0000";
			 
			 elsif (DIST_A2 < RINT * RINT) then
				  -- Círculo central negro
				  R_ARO2 <= "0000";
				  G_ARO2 <= "0000";
				  B_ARO2 <= "0000";
			else
				R_ARO2 <= "0000";
				G_ARO2 <= "0000";
				B_ARO2 <= "0000";
			end if;
		else
			R_ARO2 <= "0000";
			G_ARO2 <= "0000";
			B_ARO2 <= "0000";
		end if;
	end process;
	
	P12: process(XCOUNT, YCOUNT, EDO) is
	begin
		 -- Diferencia entre el pixel actual y el centro del aro
		 X_ARO3DIF <= to_integer(unsigned(XCOUNT)) - X_ARO3;
		 Y_ARO3DIF <= to_integer(unsigned(YCOUNT)) - Y_ARO3;
		 
		 -- Cálculo de distancia al cuadrado (para evitar raíces cuadradas)
		 DIST_A3 <= (X_ARO3DIF * X_ARO3DIF) + (Y_ARO3DIF * Y_ARO3DIF);

		if EDO = VIS and VIS_A3='1' and ENDGAME='0' then
			if (DIST_A3 >= (REXT - 1) * (REXT - 1) and DIST_A3 <= REXT * REXT) then
			  -- Contorno exterior negro
			  R_ARO3 <= "0001";
			  G_ARO3 <= "0001";
			  B_ARO3 <= "0001";
		 
			 elsif (DIST_A3 >= RINT * RINT and DIST_A3 < (REXT - 1) * (REXT - 1)) then
				  -- Relleno medio amarillo
				  R_ARO3 <= "1111";
				  G_ARO3 <= "1011";
				  B_ARO3 <= "0000";
			 
			 elsif (DIST_A3 < RINT * RINT) then
				  -- Círculo central negro
				  R_ARO3 <= "0000";
				  G_ARO3 <= "0000";
				  B_ARO3 <= "0000";
			else
				R_ARO3 <= "0000";
				G_ARO3 <= "0000";
				B_ARO3 <= "0000";
			end if;
		else
			R_ARO3 <= "0000";
			G_ARO3 <= "0000";
			B_ARO3 <= "0000";
		end if;
	end process;
	--vida 1 y vida 2
	P13: process(XCOUNT, YCOUNT, EDO) is
	begin
		if EDO = VIS and VIDASONIC>=1 and ENDGAME='0'then
			if (to_integer(unsigned(YCOUNT)) >= Y_VIDA and to_integer(unsigned(YCOUNT)) <= (Y_VIDA + 10)) and 
			   (to_integer(unsigned(XCOUNT)) >= X_VIDA1 and to_integer(unsigned(XCOUNT)) <= (X_VIDA1+10)) then 
				R_V1 <= "1100"; -- AMARILLO
				G_V1 <= "0000";
				B_V1 <= "1111";
			else
				R_V1 <= "0000";
				G_V1 <= "0000";
				B_V1 <= "0000";
			end if;
		else
			R_V1 <= "0000";
			G_V1 <= "0000";
			B_V1 <= "0000";
		end if;
	end process;
	
	P14: process(XCOUNT, YCOUNT, EDO) is
	begin
		if EDO = VIS and VIDASONIC=2 and ENDGAME='0'then
			if (to_integer(unsigned(YCOUNT)) >= Y_VIDA and to_integer(unsigned(YCOUNT)) <= (Y_VIDA + 10)) and 
			   (to_integer(unsigned(XCOUNT)) >= X_VIDA2 and to_integer(unsigned(XCOUNT)) <= (X_VIDA2+10)) then 
				R_V2 <= "1100"; -- AMARILLO
				G_V2 <= "0000";
				B_V2 <= "1111";
			else
				R_V2 <= "0000";
				G_V2 <= "0000";
				B_V2 <= "0000";
			end if;
		else
			R_V2 <= "0000";
			G_V2 <= "0000";
			B_V2 <= "0000";
		end if;
	end process;
	-- Proceso para Mezclar Fondo y Figura
	P15: process(R_FONDO, G_FONDO, B_FONDO, R_CUADRADO, G_CUADRADO, B_CUADRADO) is
	begin
		-- Si hay figura, se prioriza la figura 1 luego la 2
		if (R_CUADRADO /= "0000" or G_CUADRADO /= "0000" or B_CUADRADO /= "0000") then
			R_MIX <= R_CUADRADO;
			G_MIX <= G_CUADRADO;
			B_MIX <= B_CUADRADO;
		elsif (R_V1 /= "0000" or G_V1 /= "0000" or B_V1 /= "0000") then
			R_MIX <= R_V1;
			G_MIX <= G_V1;
			B_MIX <= B_V1;
		elsif (R_V2 /= "0000" or G_V2 /= "0000" or B_V2 /= "0000") then
			R_MIX <= R_V2;
			G_MIX <= G_V2;
			B_MIX <= B_V2;
			
		elsif (R_ENEMY /= "0000" or G_ENEMY /= "0000" or B_ENEMY /= "0000") then
			R_MIX <= R_ENEMY;
			G_MIX <= G_ENEMY;
			B_MIX <= B_ENEMY;
			
		elsif (R_BALA /= "0000" or G_BALA /= "0000" or B_BALA /= "0000") then
			R_MIX <= R_BALA;
			G_MIX <= G_BALA;
			B_MIX <= B_BALA;
			
		elsif (R_ARO1 /= "0000" or G_ARO1 /= "0000" or B_ARO1 /= "0000") then
			R_MIX <= R_ARO1;
			G_MIX <= G_ARO1;
			B_MIX <= B_ARO1;
			
		elsif (R_ARO2 /= "0000" or G_ARO2 /= "0000" or B_ARO2 /= "0000") then
			R_MIX <= R_ARO2;
			G_MIX <= G_ARO2;
			B_MIX <= B_ARO2;
			
		elsif (R_ARO3 /= "0000" or G_ARO3 /= "0000" or B_ARO3 /= "0000") then
			R_MIX <= R_ARO3;
			G_MIX <= G_ARO3;
			B_MIX <= B_ARO3;
		
			
		elsif (R_CUADRADO2 /= "0000" or G_CUADRADO2 /= "0000" or B_CUADRADO2 /= "0000") then
			R_MIX <= R_CUADRADO2;
			G_MIX <= G_CUADRADO2;
			B_MIX <= B_CUADRADO2;
		elsif (R_PLAT2 /= "0000" or G_PLAT2 /= "0000" or B_PLAT2 /= "0000") then
			R_MIX <= R_PLAT2;
			G_MIX <= G_PLAT2;
			B_MIX <= B_PLAT2;
		
		else
			R_MIX <= R_FONDO;
			G_MIX <= G_FONDO;
			B_MIX <= B_FONDO;
		end if;
	end process;

	-- Asignación final a las salidas
	R <= R_MIX;
	G <= G_MIX;
	B <= B_MIX;

end architecture;

