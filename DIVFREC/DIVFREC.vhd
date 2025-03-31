--ANDRES MENDEZ CORTEZ
--A01751729
--DIVISOR DE FRECUENCIA EJ 50MHZ A 25MHZ
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DIVFREC is
    Port (CLKI : in  std_logic;
           RESET: in  std_logic;
           CLKF: out std_logic);
end entity;

architecture RTL of DIVFREC is
    signal FF : std_logic;
begin
    process(CLKI, RESET)
    begin
        if RESET = '0' then
            FF  <= '0';  -- Reinicio del Flip-Flop
        elsif CLKI'event and CLKI ='1' then
            FF <= not FF;  -- Toggle en cada flanco de subida
        end if;
    end process;

    CLKF <= FF;  -- La salida es la frecuencia dividida

end architecture;
