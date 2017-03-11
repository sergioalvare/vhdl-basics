--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   03:31:43 01/27/2016
-- Design Name:   
-- Module Name:   C:/Users/Sergio/proyectosXilinx/picCompleto/tb_superpictop.vhd
-- Project Name:  picCompleto
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: superpictop
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

USE work.PIC_pkg.all;
USE work.RS232_test.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_pictop IS
END tb_pictop;
 
ARCHITECTURE behavior OF tb_pictop IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pictop
    PORT(
         Reset : IN  std_logic;
         Clk : IN  std_logic;
         RS232_RX : IN  std_logic;
         RS232_TX : OUT  std_logic;
         switches : OUT  std_logic_vector(7 downto 0);
         Temp_L : OUT  std_logic_vector(6 downto 0);
         Temp_H : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Reset : std_logic := '0';
   signal Clk : std_logic := '0';
   signal RS232_RX : std_logic := '0';

 	--Outputs
   signal RS232_TX : std_logic;
   signal switches : std_logic_vector(7 downto 0);
   signal Temp_L : std_logic_vector(6 downto 0);
   signal Temp_H : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 50 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pictop PORT MAP (
          Reset => Reset,
          Clk => Clk,
          RS232_RX => RS232_RX,
          RS232_TX => RS232_TX,
          switches => switches,
          Temp_L => Temp_L,
          Temp_H => Temp_H
        );



  Reset <= '0', '1' after 75 ns;
  --prueba_recepcion<= '1';
  
  RS232_RX <= '0', '1' after 50 ns;


   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 
	
	
	
	
-------------------------------------------------------------------------------
-- Sending some stuff through RS232 port
-------------------------------------------------------------------------------

  --SEND_STUFF : process
  --begin
     --RS232_RX <= '1';
--     -- Encendemos switch 4
--	  wait for 100 us;
--	  Transmit(RS232_RX, X"49");
--     wait for 40 us;
--     Transmit(RS232_RX, X"34");
--     wait for 40 us;
--     Transmit(RS232_RX, X"31");
--	  
--	  -- Encendemos switch 6
--	  wait for 100 us;
--	  Transmit(RS232_RX, X"49");
--     wait for 40 us;
--     Transmit(RS232_RX, X"36");
--     wait for 40 us;
--     Transmit(RS232_RX, X"31");
--	  
--	  -- Encendemos switch 7
--	  wait for 100 us;
--	  Transmit(RS232_RX, X"49");
--     wait for 40 us;
--     Transmit(RS232_RX, X"37");
--     wait for 40 us;
--     Transmit(RS232_RX, X"31");
--	  
--	  -- Apagamos switch 4
--	  wait for 100 us;
--	  Transmit(RS232_RX, X"49");
--     wait for 40 us;
--     Transmit(RS232_RX, X"34");
--     wait for 40 us;
--     Transmit(RS232_RX, X"30");
--	  
--	  -- Apagamos switch 7
--	  wait for 100 us;
--	  Transmit(RS232_RX, X"49");
--     wait for 40 us;
--     Transmit(RS232_RX, X"37");
--     wait for 40 us;
--     Transmit(RS232_RX, X"30");
--	  
--	  -- Ponemos el temp a 21
--	  wait for 1000 us;
--	  Transmit(RS232_RX, X"54");
--     wait for 40 us;
--     Transmit(RS232_RX, X"32");
--     wait for 40 us;
--     Transmit(RS232_RX, X"31");
--	  
--	  -- Ponemos el temp a 10
--	  wait for 1000 us;
--	  Transmit(RS232_RX, X"54");
--     wait for 40 us;
--     Transmit(RS232_RX, X"31");
--     wait for 40 us;
--     Transmit(RS232_RX, X"30");
--	
--	-- Ponemos el temp a 29
--	  wait for 1000 us;
--	  Transmit(RS232_RX, X"54");
--     wait for 40 us;
--     Transmit(RS232_RX, X"32");
--     wait for 40 us;
--     Transmit(RS232_RX, X"39");	
--     wait;
  --end process SEND_STUFF;
	
	




END;
