library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity COMP_MS is
    generic ( DATA_WIDTH: positive:=12;     
              REG_WIDTH: integer:=4;      
              CW_WIDTH: integer:=10;        
              N_ALU: integer:=2;            
              ADDR_WIDTH: positive:=4);    
    Port ( RST_i : in STD_LOGIC;
           CLK_i : in STD_LOGIC;
           PC_o: out STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
           DATA_BUS_o : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
           A_o: out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
           B_o: out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
           ALU_o : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
           FZ_o : out STD_LOGIC;
           INST_o: out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0));
end COMP_MS;

architecture Behavioral of COMP_MS is

component DATAPATH_1
    generic ( DATA_WIDTH: positive:=12;     --bus de datos parametrizado (4 bits para cada campo del formato de instruccion)
              REG_WIDTH: integer:=4;        --registros, salida de la ALU
              CW_WIDTH: integer:=10;         --enable
              N_ALU: integer:=2;            --operacion ALU
              ADDR_WIDTH: positive:=4);    --bus de direcciones y PC
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
end component;

component CONT_UNIT_1
  Generic (COP_WIDTH: integer:= 4;
           CW_WIDTH: integer:= 10);
  Port (CLK_i: in STD_LOGIC;
        RST_i: in STD_LOGIC;
        COP_i: in STD_LOGIC_VECTOR (COP_WIDTH-1 downto 0);
        FZ_i: in STD_LOGIC;
        CW_o: out STD_LOGIC_VECTOR (CW_WIDTH-1 downto 0));
end component;

signal CW: STD_LOGIC_VECTOR (CW_WIDTH-1 downto 0);
signal FZ: STD_LOGIC;
signal INST: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

begin

DATAPATH_1_0 : DATAPATH_1
  port map (
         CLK_i => CLK_i,
         RST_i => RST_i,
         CW_i => CW,
         PC_o => PC_o,
         INST_o => INST,
         DATA_BUS_o => DATA_BUS_o,
         ALU_o => ALU_o,
         A_o => A_o,
         B_o => B_o,
         FZ_o => FZ
         );
         
CONT_UNIT_1_O : CONT_UNIT_1
    port map(
        CLK_i => CLK_i,
        RST_i => RST_i,
        CW_o => CW,
        COP_i => INST(DATA_WIDTH-1 downto 2*REG_WIDTH),
        FZ_i => FZ
        );
        
INST_o <= INST;
FZ_o <= FZ;
        
dummy_process: process (CLK_i,RST_i)        --proceso dummy para el reloj, ya que doulos no lo detecta
            begin
                if RST_i='1' then
                    --
                elsif rising_edge(CLK_i) then
                    --
                end if;
            end process dummy_process;


end Behavioral;
