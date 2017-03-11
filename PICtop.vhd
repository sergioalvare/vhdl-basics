
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;	
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

entity PICtop is
  port (
    Reset    : in  std_logic;           -- Asynchronous, active low
    Clk      : in  std_logic;           -- System clock, 20 MHz, rising_edge
    RS232_RX : in  std_logic;           -- RS232 RX line
    RS232_TX : out std_logic;           -- RS232 TX line
    switches : out std_logic_vector(7 downto 0);  -- Switch status bargraph
    Temp_L   : out std_logic_vector(6 downto 0);  -- Less significant figure of T_STAT
    Temp_H   : out std_logic_vector(6 downto 0));  -- Most significant figure of T_STAT
end PICtop;

	architecture behavior of PICtop is

  component RS232top
    port (
      Reset     : in  std_logic;
      Clk       : in  std_logic;
      Data_in   : in  std_logic_vector(7 downto 0);
      Valid_D   : in  std_logic;
      Ack_in    : out std_logic;
      TX_RDY    : out std_logic;
      TD        : out std_logic;
      RD        : in  std_logic;
      Data_out  : out std_logic_vector(7 downto 0);
      Data_read : in  std_logic;
      Full      : out std_logic;
      Empty     : out std_logic);
  end component;
  
  COMPONENT cpu
    port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           ROM_Data : in  STD_LOGIC_VECTOR (11 downto 0);
           ROM_Addr : out  STD_LOGIC_VECTOR (11 downto 0);
           RAM_Addr : out  STD_LOGIC_VECTOR (7 downto 0);
           RAM_Write : out  STD_LOGIC;
           RAM_OE : out  STD_LOGIC;
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           DMA_RQ : in  STD_LOGIC;
           DMA_ACK : out  STD_LOGIC;
           SEND_comm : out  STD_LOGIC;
           DMA_READY : in  STD_LOGIC;
           Alu_op : out  alu_op;
           Index_Reg : in  STD_LOGIC_VECTOR (7 downto 0);
           FlagZ : in  STD_LOGIC;
           FlagC : in  STD_LOGIC;
           FlagN : in  STD_LOGIC;
           FlagE : in  STD_LOGIC);
    END COMPONENT;
	
	 COMPONENT ALU
    PORT ( 
		   Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           u_instruction : in alu_op;
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           Index_Reg : out  std_logic_vector(7 downto 0);
           FlagZ : out  STD_LOGIC;
           FlagC : out  STD_LOGIC;
           FlagN : out  STD_LOGIC;
           FlagE : out  STD_LOGIC
			  );
    END COMPONENT;

    COMPONENT ROM
	 PORT (
			 Instruction     : out std_logic_vector(11 downto 0);  -- Instruction bus
			 Program_counter : in  std_logic_vector(11 downto 0)
			 );
	 END COMPONENT;
	
	component dma  is
	port ( 
	  Reset : in  STD_LOGIC;
      Clk : in  STD_LOGIC;
      RCVD : in  STD_LOGIC_VECTOR (7 downto 0);
      RX_Full : in  STD_LOGIC;
      RX_Empty : in  STD_LOGIC;
      Data_Read : out  STD_LOGIC;
      ACK_out : in  STD_LOGIC;
      TX_RDY : in  STD_LOGIC;
      Valid_D : out  STD_LOGIC;
      TX_Data : out  STD_LOGIC_VECTOR (7 downto 0);
      Address : out  STD_LOGIC_VECTOR (7 downto 0);
      databus : inout  STD_LOGIC_VECTOR (7 downto 0);
      Write_en : out  STD_LOGIC;
      OE : out  STD_LOGIC;
      DMA_RQ : out  STD_LOGIC;
      DMA_ACK : in  STD_LOGIC;
      Send_comm : in  STD_LOGIC;
      READY : out  STD_LOGIC);
	end component;
	
	component ram  is
	port (
		Clk      : in    std_logic;
		Reset    : in    std_logic;
		write_en : in    std_logic;
		oe       : in    std_logic;
		address  : in    std_logic_vector(7 downto 0);
		databus  : inout std_logic_vector(7 downto 0);
		switches : out std_logic_vector(7 downto 0);
		temp_l	: out std_logic_vector(6 downto 0);
		temp_h	: out std_logic_vector(6 downto 0));
	end component;
	
	
     signal Index_Reg : std_logic_vector(7 downto 0);
     signal FlagZ : std_logic;
     signal FlagC : std_logic;
     signal FlagN : std_logic;
     signal FlagE : std_logic;
     signal u_instruction : alu_op;
	
	  signal TX_data :std_logic_vector(7 downto 0);
	  signal Valid_d :std_logic;
	  signal Ack_out :std_logic;
	  signal TX_RDY  :std_logic; 	
	  signal Data_out: std_logic_vector(7 downto 0);
	  signal Data_read:std_logic;
	  signal RX_Full:std_logic;
	  signal RX_Empty:std_logic;
	  signal ROM_data:std_logic_vector(11 downto 0);
	  signal ROM_Addr:std_logic_vector(11 downto 0);
	  signal RAM_Data:std_logic_vector(7 downto 0);
	  signal RAM_Addr:std_logic_vector(7 downto 0);
	  signal RAM_Write:std_logic;
	  signal RAM_OE:std_logic;	
  	  signal DMA_RQ:std_logic;	
	  signal DMA_ACK:std_logic;	
  	  signal DMA_Ready:std_logic;	
	  signal Send_comm:std_logic;


begin  -- behavior

  unidad_RS232: RS232top
    port map (
        Reset     => Reset,
        Clk       => Clk,
        Data_in   => TX_Data,
        Valid_D   => Valid_D,
        Ack_in    => Ack_out,
        TX_RDY    => TX_RDY,
        TD        => RS232_TX,
        RD        => RS232_RX,
        Data_out  => Data_out,
        Data_read => Data_read,
        Full      => RX_Full,
        Empty     => RX_Empty);


   unidad_cpu: cpu PORT MAP (
          Reset => Reset,
          Clk => Clk,
          ROM_Data => ROM_Data,
          ROM_Addr => ROM_Addr,
          RAM_Addr => RAM_Addr,
          --RAM_CS => RAM_CS,
          RAM_Write => RAM_Write,
          RAM_OE => RAM_OE,
          Databus => RAM_Data,
          DMA_RQ => DMA_RQ,
          DMA_ACK => DMA_ACK,
          SEND_comm => SEND_comm,
          DMA_READY => DMA_READY,
          ALU_op => u_instruction,
          Index_Reg => Index_Reg,
          FlagZ => FlagZ,
          FlagC => FlagC,
          FlagN => FlagN,
          FlagE => FlagE
        );

   unidad_alu: ALU PORT MAP (
          Reset => Reset,
          Clk => Clk,
          u_instruction => u_instruction,
          Databus => RAM_Data,
          Index_Reg => Index_Reg,
          FlagZ => FlagZ,
          FlagC => FlagC,
          FlagN => FlagN,
          FlagE => FlagE
        );	

   unidad_rom: ROM PORT MAP (
          Instruction => ROM_Data,
          Program_counter => ROM_Addr          
        );
		
	unidad_dma:dma port map(
		Reset=>Reset,
		--Clk => clk_nexys,
      Clk => Clk,
		RCVD=>Data_out,
		RX_Full=>RX_Full,
      RX_Empty=>RX_Empty,
		Data_read  =>Data_read,
      ACK_out=>Ack_out,
      TX_RDY=>TX_RDY,
		Valid_D=>Valid_D,
      TX_Data=>TX_data,
		Address=>RAM_Addr,
      databus=>RAM_Data,
      Write_en=>RAM_Write,
      OE =>RAM_OE ,
      DMA_RQ => DMA_RQ,
      DMA_ACK => DMA_ACK,
		Send_comm=>Send_comm,
      READY=>DMA_Ready);

unidad_ram:ram port map(
		Reset=>Reset,
		Clk => Clk,
		write_en =>RAM_Write,
		oe =>RAM_OE,
		address=>RAM_Addr, 
		databus=>RAM_Data, 
		switches=>switches, 
		temp_l=>temp_l,	
		temp_h=>temp_h);

end behavior;		  