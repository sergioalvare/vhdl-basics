library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dma_modulo_tx is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           --RCVD : in  STD_LOGIC_VECTOR (7 downto 0);
           --RX_Full : in  STD_LOGIC;
           --RX_Empty : in  STD_LOGIC;
           --Data_Read : out  STD_LOGIC;
           ACK_out : in  STD_LOGIC;--el rs232 
           TX_RDY : in  STD_LOGIC;
           Valid_D : out  STD_LOGIC;
           TX_Data : out  STD_LOGIC_VECTOR (7 downto 0);
           Address : out  STD_LOGIC_VECTOR (7 downto 0);
           --Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
			  Databus : in  STD_LOGIC_VECTOR (7 downto 0);
           Write_en : out  STD_LOGIC;
           OE : out  STD_LOGIC;
           --DMA_RQ : out  STD_LOGIC;
			  --DMA_ACK : in  STD_LOGIC;
           Send_comm : in  STD_LOGIC;
           READY : out  STD_LOGIC
			  --modulo_tx_esta_ocioso : out STD_LOGIC
			  );------------gestionarlo en el dma top
			  
end dma_modulo_tx;

architecture Behavioral of dma_modulo_tx is

type StateDMA_modulo_tx is (true_idle,preparar_primer_byte,esperar_ack_primer_byte,esperar_fin_envio_primer_byte,preparar_segundo_byte,esperar_ack_segundo_byte,esperar_fin_envio_segundo_byte);
signal current_state, next_state: StateDMA_modulo_tx;

signal direccion_byte_tx: std_logic_vector(7 downto 0);
signal muestreo_databus: std_logic_vector(7 downto 0);
signal Send_comm_flanco_ascendente: std_logic;

begin

	process (Send_comm,current_state,Databus,ACK_OUT,TX_RDY)
	begin
	
	--valores por defecto de las salidas:
	next_state <= current_state;
	
	--Databus<=(others=>'Z');
	Address<=(others=>'Z');
	TX_Data<=(others=>'Z');
	Write_en<='Z';
	OE<='Z';
	Valid_D<='1';
	
	if Send_comm='1' then
	READY<='0';
	else
	READY<='1';
	end if;

	
		case current_state is
		
			when true_idle =>
				if Send_comm='1' then
					next_state <= preparar_primer_byte;
				end if;
				
			when preparar_primer_byte => 
				if TX_RDY='1' and Send_comm='1' then
					Write_en<='0';
					OE<='0';
					Address<="00000100";
					TX_Data<=Databus;
					Valid_D<='0'; --aviso de que se trata de un dato valido
					next_state <= esperar_ack_primer_byte;
				end if;
			
			when esperar_ack_primer_byte =>
				Write_en<='0';
				OE<='0';
				Address<="00000100";
				TX_Data<=Databus;
				if ACK_out='0' then
					next_state <= esperar_fin_envio_primer_byte;
				end if;
			
			
			when esperar_fin_envio_primer_byte => 
					Write_en<='0';
					OE<='0';
					Address<="00000100";
					TX_Data<=Databus;
				if TX_RDY='1' then
					next_state <= preparar_segundo_byte;
				end if;
			
			when preparar_segundo_byte => 
				if TX_RDY='1' and Send_comm='1' then
					Write_en<='0';
					OE<='0';
					Address<="00000101";
					TX_Data<=Databus;
					Valid_D<='0'; --aviso de que se trata de un dato valido
					next_state <= esperar_ack_segundo_byte;
				end if;
				
			when esperar_ack_segundo_byte =>
				Write_en<='0';
				OE<='0';
				Address<="00000101";
				TX_Data<=Databus;
				if ACK_out='0' then
					next_state <= esperar_fin_envio_segundo_byte;
				end if;
			
			
			when esperar_fin_envio_segundo_byte => 
			
				Write_en<='0';
				OE<='0';
				Address<="00000101";
				TX_Data<=Databus;
				if TX_RDY='1' then
					READY<='1';
					next_state <= true_idle;
				end if;

				
			when others =>
				next_state <= true_idle;

		end case;

	end process;

process (clk,reset) 
begin
  
  if clk'event and clk = '1' then
  
		if reset = '0' then
			current_state <= true_idle;
		else
			current_state <= next_state;
		end if;
  

	 
  end if;

end process;




end Behavioral;


