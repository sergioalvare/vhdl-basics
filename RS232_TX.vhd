library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

entity RS232_TX is

port (
  reset, clk, start: in STD_LOGIC;
  data : in STD_LOGIC_VECTOR(7 downto 0);
  eot, tx : out STD_LOGIC
);

end RS232_TX;


architecture arquitectura_RS232_TX of RS232_TX is 

--DEFINO LOS ESTADOS POSIBLES DEL TRANSMISOR:
type StateTX is 
(idle, espera_final,enviando);

--DEFINO SIGNALS USADAS POR EL TRANSMISOR:
signal current_state, next_state: StateTX;

signal cuenta : integer;
--signal indice_bit: integer;

--signal permitir_cuenta, tx_rdy, clock_for_bits: std_logic;


constant max_count : integer :=174;
constant word_size : integer :=10; --8 bits de datos + start + stop

signal word_10_bits: std_logic_vector(9 downto 0);
--signal indice_de_bit: integer :=0;
signal indice_de_bit: integer;
signal enable_indice: std_logic;

signal rstCuenta, pulseEndOfCount: std_logic;

begin

--1. PROCESS COMBINACIONAL QUE CALCULA EL ESTADO SIGUIENTE
--A PARTIR DEL ESTADO ACTUAL Y LAS SIGNALS DE ENTRADA AL 
--COMPONENTE

process(start, current_state, pulseEndOfCount, indice_de_bit, data, word_10_bits)



begin

next_state<=current_state;

rstCuenta<='0';
eot<='0';
enable_indice<='1';
word_10_bits(9 downto 0) <= '1' & data(7 downto 0) & '0';
tx <='1'; --por defecto mandar bit a 1, es decir, como un bit stop permanente

 --rstCuenta<='0';

	case current_state is
	
		when idle =>
		
		--TRANSICIONES POSIBLES PARA ESTE ESTADO
			--PARA CADA TRANSICION POSIBLE, SE ESPECIFICAN LOS CAMBIOS EN LAS SALIDAS
			rstCuenta<='1';
			eot<='1';
			enable_indice<='0';
			
				--EN ESTE CASO ADEMAS TOCA VOLCAR LOS 8 BITS EN UN ARRAY DE 10: BIT DE START + 8 BITS + BIT DE STOP
--				word_10_bits(0)<='1';
--				for i in 1 to 8 loop
--				 word_10_bits(i)<=data(i-1);
--				end loop;
--				word_10_bits(9)<='0';
				
				tx <='1'; --por defecto mandar bit a 1, es decir, como un bit stop permanente

			if start='1' then
			
				next_state <= enviando;
				eot<='0';
				enable_indice<='1';
				
				
			else 
				next_state <= idle; --ante una combinacion no contemplada, se mantiene el estado
				
				--PARA CADA TRANSICION POSIBLE, SE ESPECIFICAN LOS CAMBIOS EN LAS SALIDAS
				--tx_rdy<='1';
				rstCuenta<='1';
				eot<='1';
				tx <='1'; --por defecto mandar bit a 1, es decir, como un bit stop permanente
			
			end if;
			
		--QUE HACE EN ESTE ESTADO
		--En el estado Idle, no se hace nada
		
		when enviando =>
			rstCuenta <= '0';
			enable_indice<='1';
			eot<='0';
			--TRANSICIONES POSIBLES PARA ESTE ESTADO
			if indice_de_bit=9 then 
			
				--next_state <= idle;
				next_state <= espera_final;
				--PARA CADA TRANSICION POSIBLE, SE ESPECIFICAN LOS CAMBIOS EN LAS SALIDAS
				--tx_rdy<='1';
				--rstCuenta<='1';
				--eot<='1';
				
			end if;
			
			--QUE HACE EN ESTE ESTADO
			--bit_serie<=word_10_bits(indice_de_bit);
			tx<=word_10_bits(indice_de_bit);
		
		--SIEMPRE INCLUIR UN ESTADO AL QUE LA MAQUINA VUELVE POR DEFECTO SI HAY ALGÚN ERROR U
		--OCURRE ALGO NO CONTEMPLADO A PRIORI
		
		when espera_final =>
		--espero a que se llegue al undecimo valor de la cuenta, es decir, a que indice_de_bit=10:
			if indice_de_bit=10 then --al principio del que seria el onceavo bit,
			--es decir, al final del bit cecimo, ya podemos decir que finalizo la transmision
			
				next_state <= idle;
				
				--PARA CADA TRANSICION POSIBLE, SE ESPECIFICAN LOS CAMBIOS EN LAS SALIDAS
				--tx_rdy<='1';
				rstCuenta<='1';
				eot<='1';
				
			end if;
		when others =>
		
			next_state <= idle;
			rstCuenta<='1';
			eot<='1';
			enable_indice<='0';
			
			
	end case;
	
end process;

--2. PROCESS SECUENCIAL QUE ACTUALIZA
--EL ESTADO AL RITMO DEL RELOJ DE ENTRADA
--AL COMPONENT
process(clk, reset)
begin

	if reset = '0' then
	current_state <= idle;
	
	elsif clk'event and clk='1' then
	current_state <= next_state;
	
end if;
end process;

--3. PROCESS QUE MARCA EL TIEMPO DE BIT POR PUERTO SERIE

process(clk,rstCuenta)
	
begin

	if clk'event and clk='1' then
		
		if rstCuenta='0' then 
			
			pulseEndOfCount <= '0';	
			cuenta<=cuenta+1;
			
			if cuenta=max_count then
				
				pulseEndOfCount <= '1';
				cuenta<=0;
				
				
			end if;
			
		else
	
		pulseEndOfCount <= '0';
		cuenta<=0;
			
		end if;
					

		
	end if;
		
		
	
end process;


--4. PROCESS QUE ACTUALIZA EL BIT QUE "PROCESS 1" "CONMUTA HACIA LA LINEA DE SALIDA" "bit_serie"
process(clk, reset)
begin

	if reset = '0' then
	 indice_de_bit <= 0;
	 --enable_indice <='0';
	
	elsif clk'event and clk='1' then
		if enable_indice = '0' then
			indice_de_bit <= 0;
		elsif pulseEndOfCount='1' then
			indice_de_bit <= indice_de_bit + 1;
		end if;
	end if;
end process;

end arquitectura_RS232_TX;