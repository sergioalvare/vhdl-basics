--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
--USE IEEE.std_logic_arith.all;
--USE IEEE.std_logic_unsigned.all;
USE work.PIC_pkg.all; 

--    TYPE alu_op IS (
--      nop,                                  -- no operation
--      op_lda, op_ldb, op_ldacc, op_ldid,    -- external value load
--      op_mvacc2id, op_mvacc2a, op_mvacc2b,  -- internal load
--      op_add, op_sub, op_shiftl, op_shiftr, -- arithmetic operations
--      op_and, op_or, op_xor,                -- logic operations
--      op_cmpe, op_cmpl, op_cmpg,            -- compare operations
--      op_ascii2bin, op_bin2ascii,           -- conversion operations
--      op_oeacc);                            -- output enable


entity ALU is
  port (
    Reset         : in    std_logic;    -- asynnchronous, active low
    Clk           : in    std_logic;    -- Sys clock, 20MHz, rising_edge
    u_instruction : in    alu_op;       -- u-instructions from CPU
    FlagZ         : out   std_logic;    -- Zero flag
    FlagC         : out   std_logic;    -- Carry flag 
    FlagN         : out   std_logic;    -- Nibble carry bit
    FlagE         : out   std_logic;    -- Error flag
    Index_Reg     : out   std_logic_vector(7 downto 0);   -- Index register
    Databus       : inout std_logic_vector(7 downto 0)    -- System Data bus
  );
end ALU;

architecture Behavioral of alu is

signal registroA, registroB, registroACC, registroINDEX: std_logic_vector(7 downto 0);
signal operacion: alu_op;
--signal flagZ: std_logic;
--signal flagC: std_logic;
--signal flagN: std_logic;
--signal flagE: std_logic;

begin
process(clk,Reset)
begin

if (clk'event and clk='1') then
--acciones por defecto: mantener el valor de lo que habia:
--registroA<=registroA;
--registroB<=registroB; 
--registroACC<=registroACC;
--Databus<="ZZZZZZZZ"; --o: Databus<=(others=>'Z');
operacion<=u_instruction;
--Index_Reg<=registroINDEX;

if(Reset='0') then
	registroA<="00000000";
	registroB<="00000000";
	registroACC<="00000000";
	--registroINDEX<="00000000";
	Index_Reg<="00000000";
end if;




case operacion is

      when nop				=>                                  
      when op_lda			=>--carga en el operando A
			registroA<=Databus;
		when op_ldb			=>
			registroB<=Databus;
		when op_ldacc		=>
			registroACC<=Databus;
			if (Databus = "00000000") then
				flagZ <= '1';
			end if;
		when op_ldid		=>
			registroA<=Databus;
      when op_mvacc2id	=>
			--registroINDEX<=registroACC;
			Index_Reg<=registroACC;
			
		when op_mvacc2a	=>
			registroA<=registroACC;
		when op_mvacc2b	=>
			registroB<=registroACC;
      when op_add			=>
			registroACC<=std_logic_vector(unsigned(registroA)+unsigned(registroB));
			
			if(std_logic_vector(unsigned(registroA)+unsigned(registroB))="00000000") then
				flagZ<='1';
			else 
				flagZ<='0';
			end if;
			
			if(registroA(7)='1' and registroB(7)='1') then
				flagC<='1';
			else 
				flagC<='0';
			end if;
			
			if(registroA(3)='1' and registroB(3)='1') then
				flagN<='1';
			else 
				flagN<='0';
			end if;
			
			
		when op_sub			=>
			registroACC<=std_logic_vector(unsigned(registroA)-unsigned(registroB));
			if(std_logic_vector(unsigned(registroA)-unsigned(registroB))="00000000") then
				flagZ<='1';
			else 
				flagZ<='0';
			end if;
			
			if(registroA(7)='1' and registroB(7)='1') then
				flagC<='1';
			else 
				flagC<='0';
			end if;
			
			if(registroA(3)='1' and registroB(3)='1') then
				flagN<='1';
			else 
				flagN<='0';
			end if;
			
		when op_shiftl		=>
			--registroACC <= registroACC(6 downto 0) & registroACC(7);
			registroACC <= registroACC(6 downto 0) & '0';
		when op_shiftr		=>
			--registroACC <= registroACC(0) & registroACC(7 downto 1);
			registroACC <= '0' & registroACC(7 downto 1);
      when op_and			=>
			registroACC<=registroA and registroB;
		when op_or			=>
			registroACC<=registroA or registroB;
		when op_xor			=>    
			registroACC<=registroA xor registroB;
      when op_cmpe		=>
			--con un if o con una xor y ver si el resultado es cero...
			if(registroA = registroB) then 
				flagZ<='1';
			else 
				flagZ<='0';
			end if; --notese que no afectmos a registroACC, por lo que es necesario modificar flagZ aqui, ya que el caso
			--por defecto no se disparara, ya que depende de que registroACC sea cero.
		when op_cmpl		=>
			if(registroA < registroB) then 
				flagZ<='1';
			else 
				flagZ<='0';
			end if;
		when op_cmpg		=>  
			if(registroA > registroB) then 
				flagZ<='1';
			else 
				flagZ<='0';
			end if;		
      when op_ascii2bin	=>
			--registroACC<=to_integer(unsigned(registroA))-48;--en la tabla ascii el cero ocupa la posicion/es el valor
			-- 48 de entre la posicion /el valor 0 a la /al 127
			registroACC<=std_logic_vector(to_unsigned(to_integer(unsigned(registroA))-48,8));
			if(to_integer(unsigned(registroACC)) > 9 or to_integer(unsigned(registroA))<48) then --si nos salimos de rango hay error
				flagE<='1';
			else 
				flagE<='0';
			end if;
		when op_bin2ascii	=>
			registroACC<=std_logic_vector(to_unsigned(to_integer(unsigned(registroA))+48,8));	
      --when op_oeacc		=>
			--Databus<=registroACC;---cambiar esta a combinacional
		
	
	when others =>
	
	end case;
end if;

end process;


process(operacion, registroACC)
begin
	if (operacion=op_oeacc) then
		Databus<=registroACC;
	else 
		Databus<="ZZZZZZZZ";
	end if;
end process;



--process(registroACC)
--begin
--if(registroACC="00000000") then 
--	flagZ<='1';
--else 
--	flagZ<='0';
--end if;
--end process;
end Behavioral;