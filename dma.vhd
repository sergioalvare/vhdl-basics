library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dma is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           RCVD : in  STD_LOGIC_VECTOR (7 downto 0);
           RX_Full : in  STD_LOGIC;
           RX_Empty : in  STD_LOGIC;
           Data_Read : out  STD_LOGIC;
           ACK_out : in  STD_LOGIC;
           TX_RDY : in  STD_LOGIC;
           Valid_D : out  STD_LOGIC;
           TX_Data : out  STD_LOGIC_VECTOR (7 downto 0);
           Address : out  STD_LOGIC_VECTOR (7 downto 0);
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           Write_en : out  STD_LOGIC;
           OE : out  STD_LOGIC;
           DMA_RQ : out  STD_LOGIC;
           DMA_ACK : in  STD_LOGIC;
           Send_comm : in  STD_LOGIC;
           READY : out  STD_LOGIC);

end dma;



architecture Behavioral of dma is


component dma_modulo_tx is
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
           Databus : in  STD_LOGIC_VECTOR (7 downto 0);
           Write_en : out  STD_LOGIC;
           OE : out  STD_LOGIC;
           --DMA_RQ : out  STD_LOGIC;
			  --DMA_ACK : in  STD_LOGIC;
           Send_comm : in  STD_LOGIC;
           READY : out  STD_LOGIC
			  --modulo_tx_esta_ocioso : out STD_LOGIC
			  );------------gestionarlo en el dma top
			  
end component;


component dma_modulo_rx is
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
end component;

--signal modulo_tx_esta_ocioso :  STD_LOGIC;
--signal modulo_rx_esta_ocioso :  STD_LOGIC;
signal DMA_RQ_rx :  STD_LOGIC;
--signal READY :  STD_LOGIC;

begin

Transmisor: dma_modulo_tx
    port map ( reset => reset,
           clk => clk,
           ACK_out => ACK_out,
           TX_RDY => TX_RDY,
           Valid_D => Valid_D,
           TX_Data => TX_Data,
           Address => Address,
           Databus => Databus,
           Write_en => Write_en,
           OE => OE,
           --DMA_RQ => DMA_RQ,
			  --DMA_ACK => DMA_ACK,
           Send_comm => Send_comm,
           READY => READY
			  --modulo_tx_esta_ocioso => modulo_tx_esta_ocioso
			  );------------gestionarlo en el dma top

Receptor: dma_modulo_rx
    port map ( reset => reset,
           clk => clk,
           RCVD => RCVD,
           RX_Full => RX_Full,
           RX_Empty => RX_Empty,
           Data_Read => Data_Read,
           Address => Address,
           Databus => Databus,
           Write_en => Write_en,
           OE => OE,
           DMA_RQ_rx => DMA_RQ_rx,
           DMA_ACK => DMA_ACK,
			  Send_comm => Send_comm
			  --modulo_rx_esta_ocioso => modulo_rx_esta_ocioso
			  );
			  
			  
			  

process(Send_comm,DMA_RQ_rx)
begin

	if Send_comm='0' and DMA_RQ_rx='1' then --si el transmisor no esta haciendo nada, el receptor puede
	--pedir los buses
	DMA_RQ<='1';
	else
	DMA_RQ<='0';
	end if;
end process;
			  

end Behavioral;

