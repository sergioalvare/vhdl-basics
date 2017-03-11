library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dma_modulo_rx is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           RCVD : in  STD_LOGIC_VECTOR (7 downto 0);
           RX_Full : in  STD_LOGIC;
           RX_Empty : in  STD_LOGIC;
           Data_Read : out  STD_LOGIC;
           --ACK_out : in  STD_LOGIC;
           --TX_RDY : in  STD_LOGIC;
           --Valid_D : out  STD_LOGIC;
           --TX_Data : out  STD_LOGIC_VECTOR (7 downto 0);
           Address : out  STD_LOGIC_VECTOR (7 downto 0);
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           Write_en : out  STD_LOGIC;
           OE : out  STD_LOGIC;--hay que ponerla a un valor tal que la ram no vuelque un dato en el bus de datos mientras
			  --el modulo dma rx trata de escribir. MUY IMPORTANTE.
           DMA_RQ_rx : out  STD_LOGIC;
           DMA_ACK : in  STD_LOGIC;
           Send_comm : in  STD_LOGIC
           --READY : out  STD_LOGIC);
			  --modulo_rx_esta_ocioso : out STD_LOGIC------------gestionarlo en el dma top
			  );
end dma_modulo_rx;

architecture Behavioral of dma_modulo_rx is

type StateDMA_modulo_rx is (idle, solicitar_buses, leer_rs232, liberar_buses);
signal current_state, next_state: StateDMA_modulo_rx;

signal direccion_byte_rx,direccion_byte_rx_next: std_logic_vector(7 downto 0);


begin

	process(current_state,RCVD,RX_Empty,DMA_ACK,direccion_byte_rx,Send_comm)
	begin
	
	--valores por defecto de las salidas:
	next_state <= current_state;
	DMA_RQ_rx<='0';
	
	
	Databus<=(others=>'Z');
	Address<=(others=>'Z');
	Write_en<='Z';
	OE<='Z';
	
	Data_Read<='0';
	direccion_byte_rx_next<=direccion_byte_rx;
	--modulo_rx_esta_ocioso<='0';-----------------

	
	--direccion_byte_rx<="00000000";--valor por defecto
	
		case current_state is

			when idle =>
				--modulo_rx_esta_ocioso<='1';--Efectivamente, el modulo esta ocioso
				if RX_Empty='0' then
					next_state <= solicitar_buses;
					--modulo_rx_esta_ocioso<='0';
				end if;
				
				
			when solicitar_buses =>
				--modulo_rx_esta_ocioso<='0';
				if Send_comm='0' then--si la cpu no quiere enviar (le doy prioridad a los envios solicitados por la cpu)
					--modulo_rx_esta_ocioso<='0';
					DMA_RQ_rx<='1';
					if DMA_ACK='1' then
						next_state <= leer_rs232;
						Data_Read<='1';--con esto la fifo pone un byte para que lo lea el dma
					end if;
				else
				end if;
				
			when leer_rs232 => 
			
				
			   Databus<=RCVD;
				Write_en<='1';
				OE<='1';--mientras escribo no quiero que la ram ponga un dato en el bus de datos, porque machacaria
				--lo que intento escribir
				Address<=direccion_byte_rx;
				direccion_byte_rx_next<=direccion_byte_rx+"00000001";
				next_state <= liberar_buses;
				if (conv_Integer(direccion_byte_rx)) = 2 then
				  next_state <= leer_rs232;
				end if;
				if (conv_Integer(direccion_byte_rx))=3 then--realizar la escritura del flag
					Databus<="11111111";
					direccion_byte_rx_next<="00000000";
					--Write_en<='1';
					--OE<='1';
					--Address<=direccion_byte_rx;
				end if;
				

			when liberar_buses =>

				
					DMA_RQ_rx<='0';
					next_state <= idle;
					

			when others =>
				next_state <= idle;
		end case;

	end process;

process (clk,reset) 
begin
  
  if clk'event and clk = '1' then
  
		if reset = '0' then
			current_state <= idle;
			direccion_byte_rx<="00000000";
		else
			current_state <= next_state;
			direccion_byte_rx<=direccion_byte_rx_next;
		end if;

	 
  end if;

end process;


end Behavioral;


