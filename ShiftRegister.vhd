
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

ENTITY ShiftRegister IS 
  	PORT	(
            	
			reset, clk, enable, D : IN STD_LOGIC ;           
            Q : out STD_LOGIC_VECTOR (7 DOWNTO 0)
	   	);
END ShiftRegister ;

ARCHITECTURE behavior_shift_reg OF ShiftRegister IS

SIGNAL reg_int  : STD_LOGIC_VECTOR (7 DOWNTO 0);

begin

Q<=reg_int;

process(clk, reset)
begin

	if reset='0' then --se dice activo a nivel bajo 
--para shift_register, fifo,rx, tx

		reg_int<="00000000";
	
	elsif clk'event and clk='1' then
		if enable='1' then
			reg_int <= D & reg_int(7 downto 1);
		end if;
	
	end if;


end process;

end behavior_shift_reg;