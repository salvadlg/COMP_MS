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
           PUSH_i: in STD_LOGIC;
           FZ_o : out STD_LOGIC;
           CW_o : out STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0);
           CATHODE_o: out STD_LOGIC_VECTOR (6 downto 0);
           ANODE_o: out STD_LOGIC_VECTOR (7 downto 0));
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
        PUSH_i: in STD_LOGIC;
        CW_o: out STD_LOGIC_VECTOR (CW_WIDTH-1 downto 0));
end component;

component EDGE_DETECTOR_1 
	generic(END_COUNT: integer:= 30000000);
    Port ( CLK_i : in STD_LOGIC;
           RST_i : in STD_LOGIC;
           PUSH_i : in STD_LOGIC;
           PULSE_o : out STD_LOGIC);
end component;

component DISP7SEG_8ON 
    generic(WIDTH: integer:= 4);
    Port ( CLK_i : in STD_LOGIC;
           RST_i : in STD_LOGIC;
           DATA0_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           DATA1_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           DATA2_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           DATA3_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           DATA4_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           DATA5_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           DATA6_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           DATA7_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           CATHODE_o: out STD_LOGIC_VECTOR (6 downto 0);
           ANODE_o: out STD_LOGIC_VECTOR (7 downto 0));
end component;


signal CWA: STD_LOGIC_VECTOR (CW_WIDTH-1 downto 0);
signal CWB: STD_LOGIC_VECTOR (CW_WIDTH-1 downto 0);
signal FZ: STD_LOGIC;
signal INST: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
signal PULSE: STD_LOGIC;
signal DATA0, DATA1, DATA2, DATA3: STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);

begin

DATAPATH_1_0 : DATAPATH_1
  port map (
         CLK_i => CLK_i,
         RST_i => RST_i,
         CW_i => CWB,
         PC_o => DATA3,
         INST_o => INST,
         ALU_o => DATA0,
         A_o => DATA2,
         B_o => DATA1,
         FZ_o => FZ
         );
         
CONT_UNIT_1_O : CONT_UNIT_1
    port map(
        CLK_i => CLK_i,
        RST_i => RST_i,
        CW_o => CWA,
        COP_i => INST(DATA_WIDTH-1 downto 2*REG_WIDTH),
        FZ_i => FZ,
        PUSH_i => PULSE
        );
        
EDGE_DETECTOR_CW4 : EDGE_DETECTOR_1
port map(
        CLK_i => CLK_i,
        RST_i => RST_i,
        PUSH_i => CWA(4),
        PULSE_o => CWB(4)
        );
        
EDGE_DETECTOR_CW7 : EDGE_DETECTOR_1
port map(
        CLK_i => CLK_i,
        RST_i => RST_i,
        PUSH_i => CWA(7),
        PULSE_o => CWB(7)
        );
        
DEBOUNCE_1 : EDGE_DETECTOR_1
port map(
        CLK_i => CLK_i,
        RST_i => RST_i,
        PUSH_i => PUSH_i,
        PULSE_o => PULSE
        );
        
DISPLAY : DISP7SEG_8ON
port map(
        CLK_i => CLK_i,
        RST_i => RST_i,
        DATA0_i => DATA0,
        DATA1_i => DATA1,
        DATA2_i => DATA2,
        DATA3_i => INST(3 downto 0),
        DATA4_i => INST(7 downto 4),
        DATA5_i => INST(11 downto 8),
        DATA6_i => DATA3,
        DATA7_i => "0000",
        CATHODE_o => CATHODE_o,
        ANODE_o => ANODE_o
        );
        
FZ_o <= FZ;
CWA(9 downto 8) <= CWB(9 downto 8);
CWA(6 downto 5) <= CWB(6 downto 5);
CWA(3 downto 0) <= CWB(3 downto 0);
CW_o <= CWA;

end Behavioral;
