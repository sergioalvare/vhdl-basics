library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

entity RS232_RX is

port (
  reset, clk: in STD_LOGIC;
  LineRD_in: in STD_LOGIC;
  Code_out: out STD_LOGIC;
  Valid_out, Store_out : out STD_LOGIC
);

end RS232_RX;


architecture arquitectura_RS232_RX of RS232_RX is 

--DEFINO LOS ESTADOS POSIBLES DEL TRANSMISOR:
type StateRX is 
(idle, revdata_info_util, revdata_bit_stop, esperandoMedioBit);

--DEFINO SIGNALS USADAS POR EL RECEPTOR:
signal current_state, next_state: StateRX;
signal rstCuenta, pulseEndOfCount: std_logic;
signal indice_bit: integer;

signal cuenta : integer;
signal max_count : integer;--lo que dura un bit

--constant max_count : integer :=174;
--constant half_max_count : integer :=max_count/2;


--signal contar_medio_periodo_de_bit: std_logic;



begin

--1. PROCESS COMBINACIONAL QUE CALCULA EL ESTADO SIGUIENTE
--A PARTIR DE: EL ESTADO ACTUAL Y LAS SIGNALS DE ENTRADA AL COMPONENTE

process(LineRD_in, current_state, pulseEndOfCount, indice_bit)
begin

	next_state <= current_state;
	store_out<='0';
	valid_out<='0';
	rstCuenta<='0';		
	max_count<=174;
	--contar_medio_periodo_de_bit<='0';
	--code_out <= '0';
	
	case current_state is
	
		when idle =>
			--QUE HACE EN ESTE ESTADO:
			--Se usa esto porque se especifica que se quiere usar un registro de desplazamiento
			--Store_out<='0';
			rstCuenta <= '1';
			
		--TRANSICIONES POSIBLES PARA ESTE ESTADO

			if LineRD_in='0' then
			
				next_state <= esperandoMedioBit;
				
				--PARA CADA TRANSICION POSIBLE, SE ESPECIFICAN LOS CAMBIOS EN LAS SALIDAS
				--max_count:=174/2;--la primera vez que cuentes, cuenta medio periodo de bit
				--contar_medio_periodo_de_bit<='1';
				max_count<=174/2;
			end if;
			

		
		when esperandoMedioBit=>
			rstCuenta<='0';		
			max_count<=174/2;
			--if indice_bit=1 then
			
			--TRANSICION POSIBLE:
			if pulseEndOfCount = '1' then
				next_state <= revdata_info_util;
			end if;
			
		when revdata_info_util => --estado de recepcion de los 8 bits, sin el stop			
			
			if pulseEndOfCount = '1' then
				Valid_out <= '1';
				--TRANSICIONES POSIBLES PARA ESTE ESTADO
			end if;	

			if indice_bit=9 then --si ya ha contado 1+8 bits 
				next_state <= revdata_bit_stop;
				--PARA CADA TRANSICION POSIBLE, SE ESPECIFICAN LOS CAMBIOS EN LAS SALIDAS
				--Indico que el dato es valido al registro de desplazamiento, y este lo volcara a la FIFO.
			end if;

			--QUE HACE EN ESTE ESTADO
			--Code_out<=LineRD_in; --Si estamos recibiendo bits y aun no hemos recibido 1+8, conectamos la linea serie directamente a la salida, que 
			--ira conectada al registro de desplazamiento
			Store_out<='0';
			rstCuenta<='0'; --a partir de ahora permito contar sin parar, hasta llegada del bit de stop.....		
			max_count<=174;
			
		when revdata_bit_stop => --estado de recepcion de los 8 bits, sin el stop
			rstCuenta<='0';	--(sigo permitiendo contar)
			max_count<=174;
		
			if pulseEndOfCount = '1' then
				
				--TRANSICIONES POSIBLES PARA ESTE ESTADO
				if indice_bit=9 then 
					next_state <= idle;
					valid_out <= '0';
					--PARA CADA TRANSICION POSIBLE, SE ESPECIFICAN LOS CAMBIOS EN LAS SALIDAS
					store_out<='1';--Indico que el dato es valido al registro de desplazamiento, y este lo volcara a la FIFO.
				end if;
			end if;	
			--QUE HACE EN ESTE ESTADO
			--Code_out<=LineRD_in; --Si estamos recibiendo bits y aun no hemos recibido 1+8, conectamos la linea serie directamente a la salida, que 
			--ira conectada al registro de desplazamiento
			--Store_out<='0';

		--SIEMPRE INCLUIR UN ESTADO AL QUE LA MAQUINA VUELVE POR DEFECTO SI HAY ALGÚN ERROR U
		--OCURRE ALGO NO CONTEMPLADO A PRIORI
		when others =>
			next_state <= idle;
			
	end case;
	
end process;

Code_out<=LineRD_in;

--2. PROCESS SECUENCIAL QUE ACTUALIZA
--EL ESTADO AL RITMO DEL RELOJ DE ENTRADA
--AL COMPONENT
process(clk, reset)
begin

	if reset = '0' then
	current_state <= idle;
	--valid_out <= '0';
	--Store_out<='0';
	
	elsif clk'event and clk='1' then
	current_state <= next_state;

	
end if;
end process;


--3. PROCESS QUE MARCA EL TIEMPO DE BIT POR PUERTO SERIE. "cuenta" es el numero de ciclos de reloj que dira un bit.
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
		--rstCuenta<='0';
			
		end if;
					

		
	end if;
	
	
end process;


--4. PROCESS QUE CUENTA EL NUMERO DE BITS RECIBIDOS, DE 0 A 9 (de los cuales del 1 al 8 serán los 0 a 7 de la palabra de informacion; el otro es el de start)
process(clk, rstCuenta, pulseEndOfCount)
begin

	if rstCuenta = '1' then
	 indice_bit <= 0;
	
	elsif clk'event and clk='1' then
		if pulseEndOfCount='1' then
			indice_bit <= indice_bit + 1; --esta pensado para contar de 1 a 9
		end if;
		
	end if;
end process;

end arquitectura_RS232_RX;