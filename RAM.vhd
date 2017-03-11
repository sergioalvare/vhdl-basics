
--LIBRARY IEEE;
--USE IEEE.std_logic_1164.all;
--USE IEEE.std_logic_arith.all;
--USE IEEE.std_logic_unsigned.all;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.NUMERIC_STD.ALL;

USE work.PIC_pkg.all;

ENTITY ram IS
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0);
	
	switches  : out std_logic_vector(7 downto 0);
	TEMP_h  : out    std_logic_vector(6 downto 0);
	TEMP_L  : out    std_logic_vector(6 downto 0));
END ram;

ARCHITECTURE behavior OF ram IS

  SIGNAL contents_ram_registros : array8_ram(63 downto 0);
  SIGNAL contents_ram_pg : array8_ram(255 downto 64);--zona de "proposito general"
  signal output_enable_ram_registros, output_enable_ram_pg, write_en_ram_registros, write_en_ram_pg: std_logic;
  signal prueba: std_logic_vector(7 downto 0);

BEGIN

process(oe,write_en,address)
begin

output_enable_ram_registros<='1';--por defecto desactivado. Es activo por nivel bajo.
output_enable_ram_pg<='1';--por defecto desactivado. Es activo por nivel bajo.

write_en_ram_registros <= '0';--por defecto desactivado. Es activo por nivel alto.
write_en_ram_pg <= '0';--por defecto desactivado. Es activo por nivel alto.

	if to_integer(unsigned(address))>=64 then
	
		if oe = '0' then
			output_enable_ram_pg<='0';--notese que es activo por nivel bajo
		end if;
		
		if write_en = '1' then
			write_en_ram_pg <= '1';
		end if;

	else 

		if oe = '0' then
			output_enable_ram_registros<='0';--notese que es activo por nivel bajo
		end if;
		
		if write_en = '1' then
			write_en_ram_registros <= '1';
		end if;

	end if;

end process;


process (clk)  -- no reset
begin
  
  if clk'event and clk = '1' then
  
    if write_en_ram_registros = '1' then
      contents_ram_registros(to_integer(unsigned(address))) <= databus;
    end if;
	 
	  if write_en_ram_pg = '1' then
      contents_ram_pg(to_integer(unsigned(address))) <= databus;
    end if;
	 
  end if;

end process;

--databus <= contents_ram_pg(conv_integer(address)) when output_enable_ram_pg = '0' else (others => 'Z');
--databus <= contents_ram_pg(to_integer(unsigned(address))) when output_enable_ram_pg = '0' else (others => 'Z');
--databus <= contents_ram_registros(conv_integer(address)) when output_enable_ram_registros = '0' else (others => 'Z');
--databus <= contents_ram_registros(to_integer(unsigned(address))) when output_enable_ram_registros = '0' else (others => 'Z');

process (address,output_enable_ram_registros,output_enable_ram_pg)
begin
  
	if output_enable_ram_pg = '0' then
		databus <= contents_ram_pg(to_integer(unsigned(address)));
		prueba<="00000001";
	elsif output_enable_ram_registros = '0' then
		databus <= contents_ram_registros(to_integer(unsigned(address)));
		prueba<="00000010";
	else
	databus <= "ZZZZZZZZ";
	prueba<="00000100";
	 
  end if;

end process;




-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Decodificador de BCD a 7 segmentos
-------------------------------------------------------------------------
with contents_ram_registros(49)(7 downto 4) select
Temp_H <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1110111" when "1010",  -- A
    "1111100" when "1011",  -- B
    "0111001" when "1100",  -- C
    "1011110" when "1101",  -- D
    "1111001" when "1110",  -- E
    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0
	 
with contents_ram_registros(49)(3 downto 0) select
Temp_L <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1110111" when "1010",  -- A
    "1111100" when "1011",  -- B
    "0111001" when "1100",  -- C
    "1011110" when "1101",  -- D
    "1111001" when "1110",  -- E
    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0
-------------------------------------------------------------------------

process (clk)
begin

  if clk'event and clk = '1' then
		for I in 0 to 7 loop
			switches(I) <= contents_ram_registros(I+16)(0);
		end loop;
	end if;
end process;

END behavior;

