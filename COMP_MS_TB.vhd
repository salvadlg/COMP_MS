
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity COMP_MS_tb is
end;

architecture bench of COMP_MS_tb is

  component COMP_MS
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
  end component;
  
  constant DATA_WIDTH: positive:=12;     
  constant REG_WIDTH: integer:=4;      
  constant CW_WIDTH: integer:=10;        
  constant N_ALU: integer:=2;            
  constant ADDR_WIDTH: positive:=4;

  signal RST_i: STD_LOGIC;
  signal CLK_i: STD_LOGIC;
  signal PC_o: STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
  signal DATA_BUS_o: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
  signal A_o: STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
  signal B_o: STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
  signal ALU_o: STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
  signal FZ_o: STD_LOGIC;
  signal INST_o: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  -- Insert values for generic parameters !!
  uut: COMP_MS generic map ( DATA_WIDTH => DATA_WIDTH,
                             REG_WIDTH  => REG_WIDTH,
                             CW_WIDTH   => CW_WIDTH,
                             N_ALU      => N_ALU,
                             ADDR_WIDTH =>  ADDR_WIDTH)
                  port map ( RST_i      => RST_i,
                             CLK_i      => CLK_i,
                             PC_o       => PC_o,
                             DATA_BUS_o => DATA_BUS_o,
                             A_o        => A_o,
                             B_o        => B_o,
                             ALU_o      => ALU_o,
                             FZ_o       => FZ_o,
                             INST_o     => INST_o );

  stimulus: process
  begin

    RST_i <= '1';
    wait for 5 ns;
    RST_i <= '0';
    wait for 5 ns;
    
    wait for 500 ns;

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      CLK_i <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
