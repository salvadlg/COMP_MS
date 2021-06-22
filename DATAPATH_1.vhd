--SALVADOR DELGADO ARROYO

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DATAPATH_1 is
    generic ( DATA_WIDTH: positive:=12;     --bus de datos parametrizado (4 bits para cada campo del formato de instruccion)
              REG_WIDTH: integer:=4;        --registros, salida de la ALU
              CW_WIDTH: integer:=10;         --enable
              N_ALU: integer:=2;            --operacion ALU
              ADDR_WIDTH: positive:=4);     --bus de direcciones y PC
    Port ( RST_i : in STD_LOGIC;
           CLK_i : in STD_LOGIC;
           PC_o: out STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
           DATA_BUS_o : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
           A_o: out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
           B_o: out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
           CW_i : in STD_LOGIC_VECTOR (CW_WIDTH-1 downto 0);
           ALU_o : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
           FZ_o : out STD_LOGIC;
           INST_o: out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0));
    end DATAPATH_1;

architecture Behavioral of DATAPATH_1 is

--Señales para la ALU
signal A,B: unsigned(REG_WIDTH-1 downto 0);                             --registros A y B
signal FZ: STD_LOGIC;                                                   --bandera de 0
signal RESULT : unsigned(REG_WIDTH-1 downto 0);                         --resultado de la ALU
signal ZERO: unsigned (DATA_WIDTH-1 downto 0) := (others => '0');       --señal de ceros para comparar con el resultado de la ALU
signal DATA_BUS: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);               --bus de datos

--Señales para la RAM
type RAM_TYPE is array(2**ADDR_WIDTH-1 downto 0) of
    std_logic_vector(DATA_WIDTH-1 downto 0);                            --RAM de 16x12
    signal RAM : RAM_TYPE := 
    ( 0 =>  "000110011000",       --instruccion suma. cod. op = 0001 op1 = 8 op2 = 9    ADD 8, 9
      1 =>  "000011111100",       --instruccion mov. cod. op = 0000 op1 = F op2 = 12    MOV F, 12
      2 =>  "001011011101",       --instruccion cmp. cod. op = 0010 op1 = 13 op2 = 13   CMP 13, 13
      3 =>  "001100000110",       --instruccion salto. cod. op = 0011 op2 = 6           BEZ 6
      4 =>  "000000000000",       --instruccion vacia
      5 =>  "000000000000",       --instruccion vacia
      6 =>  "000110011000",       --instruccion suma. cod. op = 0001 op1 = 8 op2 = 9    ADD 8, 9
      7 =>  "001011011101",       --instruccion cmp. cod. op = 0010 op1 = 13 op2 = 13   CMP 13, 13
      8 =>  "000000000001",       --dato = 1
      9 =>  "000000000010",       --dato = 2
      10 =>  "000000000011",      --dato = 3
      11 =>  "000000000011",      --dato = 3 
      12 =>  "000000000100",      --dato = 4
      13 =>  "000000000101",      --dato = 5
      14 =>  "000000000000",      --dato vacio
      15 =>  "000000000000");     --dato vacio

      
signal ADDR_RAM: STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);              --bus de direcciones
      
--señal de PC
signal PC: STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);

--señal registro de instrucciones
signal REG_INST: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);               --registro de instrucciones de 12 bits
   
begin

    --CLK registros 
    process (CLK_i,RST_i)
        begin
            if RST_i='1' then
                A <= (others => '0');
                B <= (others => '0');
                PC <= (others => '0');
                REG_INST <= (others => '0');
            elsif rising_edge(CLK_i) then
                if CW_i(0) = '1' then
                    A <= unsigned(DATA_BUS(REG_WIDTH-1 downto 0));      --los datos estarán en la parte menos significativa
                end if;
                if CW_i(1) = '1' then
                    B <= unsigned(DATA_BUS(REG_WIDTH-1 downto 0));      --los datos estarán en la parte menos significativa
                end if;
                if CW_i(4) = '1' then
                    REG_INST <= DATA_BUS;                               --carga del registro de instrucciones
                end if;
                if CW_i(7) = '1' then
                    PC <= STD_LOGIC_VECTOR(unsigned(ADDR_RAM) + 1);     --PC+1
                end if;
            end if;
    end process;

    --ALU
    with CW_i(CW_WIDTH-1 downto CW_WIDTH-N_ALU) select
        RESULT <= RESULT when "00",     --para que por la ALU se mantengan los valores
                  A + B when "01",      --ADD A,B
                  B when "10",          --MOV B
                  A - B when others;    --CMP A,B
    
    --bandera de cero (FZ)          
    process (RST_i, CLK_i)
        begin
            if RST_i = '1' then
                FZ <= '0';
            elsif rising_edge(CLK_i) then 
                if CW_i(2) = '1' then
                    if RESULT = ZERO then
                        FZ <= '1';
                    else
                        FZ <= '0';
                    end if;
                end if;             
            end if;
    end process; 
    
    --RAM
    process (CLK_i)
        begin
            if rising_edge(CLK_i) then
                -- Operación de LECTURA/ESCRITURA síncrona
                if CW_i(3) = '1' then
                    RAM(to_integer(unsigned(ADDR_RAM)))(REG_WIDTH-1 downto 0) <= STD_LOGIC_VECTOR(RESULT);  --guardamos en la parte menos significativa el resultado
                    -- El dato que se lee, es el mismo que se escribe
                    DATA_BUS(REG_WIDTH-1 downto 0) <= STD_LOGIC_VECTOR(RESULT);
                else
                    -- Operación de SOLO LECTURA SÍNCRONA
                    DATA_BUS <= RAM(to_integer(unsigned(ADDR_RAM))); 
                end if;
            end if;
     end process;   
     
     --MUX RAM
     with CW_i(6 downto 5) select
        ADDR_RAM <= PC                                                  when "00",
                    REG_INST(DATA_WIDTH-REG_WIDTH-1 downto REG_WIDTH)   when "10",      --(7 downto 4) salida del registro Fuente
                    REG_INST(REG_WIDTH-1 downto 0)                      when "11",      --(3 downto 0) salida del registro Destino
                    (others => '0')                                     when others;        
              
ALU_o <= STD_LOGIC_VECTOR(RESULT);
A_o <= STD_LOGIC_VECTOR(A);
B_o <= STD_LOGIC_VECTOR(B);
FZ_o <= FZ;
DATA_BUS_o <= DATA_BUS;
PC_o <= PC;
INST_o <= REG_INST;
              
end Behavioral;

