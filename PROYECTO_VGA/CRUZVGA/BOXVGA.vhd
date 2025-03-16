--ANDRES MENDEZ CORTEZ
--A01751729
--PROGRAMA QUE HACE UNA CRUZ EN VGA
library ieee;
use ieee.std_logic_1164.all;

entity BOXVGA is
	port(CLK,RST,START,JUMP,SWF,SWB,PERSONAJE: in std_logic;
		  VSINC,HSINC: out std_logic;
		  R,G,B: out std_logic_vector(3 downto 0));

end entity;
	
architecture RTL of BOXVGA is
	component DIVFREC is
    Port (CLKI : in  std_logic;
           RESET: in  std_logic;
           CLKF: out std_logic);
	end component;
	
	component CONTMOD525 is
	port(CLK,RST,STRT: in std_logic;
	COUNT: out std_logic_vector(9 downto 0));
	end component;
	
	component CONTMOD800 is
	port(CLK,RST,STRT: in std_logic;
	COUNT: out std_logic_vector(9 downto 0);
	CO: out std_logic:='0');
	end component;
	
	component YSINCVGA is 
	port( CLOCK,RESET,START: in std_logic;
			YCOUNT: in std_logic_vector(9 downto 0);
			YSTATE: out std_logic_vector(1 downto 0);
			VSINC: out std_logic);
	end component;
	
	component XSINCVGABOX is 
	port( CLOCK,RESET,START,JUMP,SWF,SWB,VSINC,PER: in std_logic;
			XCOUNT,YCOUNT: in std_logic_vector(9 downto 0);	
			YSTATE: in std_logic_vector(1 downto 0);
			R,G,B: out std_logic_vector(3 downto 0);
			HSINC: out std_logic);
	end component;
	
	signal CLK25,OV800: std_logic;
	signal COUNT800,COUNT525: std_logic_vector(9 downto 0);
	signal EDOV: std_logic_vector(1 downto 0);
	signal YSINC: std_logic;
	
	begin
	
	I0:DIVFREC port map(CLK,RST,CLK25);
	I1:CONTMOD800 port map(CLK25,RST,START,COUNT800,OV800);
	I2:CONTMOD525 port map(OV800,RST,START,COUNT525);
	I3:YSINCVGA port map(CLK25,RST,START,COUNT525,EDOV,YSINC);
	I4:XSINCVGABOX port map(CLK25,RST,START,not(JUMP),SWF,SWB,YSINC,PERSONAJE,COUNT800,COUNT525,EDOV,R,G,B,HSINC);
	VSINC<=YSINC;

end architecture;