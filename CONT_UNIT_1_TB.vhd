library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity CONT_UNIT_1_tb is
end;

architecture bench of CONT_UNIT_1_tb is

  component CONT_UNIT_1
    Generic (COP_WIDTH: integer:= 4;
             CW_WIDTH: integer:= 10);
    Port (CLK_i: in STD_LOGIC;
          RST_i: in STD_LOGIC;
          COP_i: in STD_LOGIC_VECTOR (COP_WIDTH-1 downto 0);
          FZ_i: in STD_LOGIC;
          CW_o: out STD_LOGIC_VECTOR (CW_WIDTH-1 downto 0));
  end component;
  
  constant COP_WIDTH: integer:= 4;
  constant CW_WIDTH: integer:= 10;

  signal CLK_i: STD_LOGIC;
  signal RST_i: STD_LOGIC;
  signal COP_i: STD_LOGIC_VECTOR (COP_WIDTH-1 downto 0);
  signal FZ_i: STD_LOGIC;
  signal CW_o: STD_LOGIC_VECTOR (CW_WIDTH-1 downto 0);

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  -- Insert values for generic parameters !!
  uut: CONT_UNIT_1 generic map ( COP_WIDTH => COP_WIDTH,
                                 CW_WIDTH  =>  CW_WIDTH)
                      port map ( CLK_i     => CLK_i,
                                 RST_i     => RST_i,
                                 COP_i     => COP_i,
                                 FZ_i      => FZ_i,
                                 CW_o      => CW_o );

  stimulus: process
  begin

    FZ_i <= '0';

    RST_i <= '1';
    wait for 5 ns;
    RST_i <= '0';
    wait for 5 ns;

    --ADD
    COP_i <= "0001";
    wait for 90 ns;
    
    --MOV
    COP_i <= "0000";
    wait for 70 ns;
    
    --CMP
    COP_i <= "0010";
    wait for 80 ns;
    
    --BEZ
    COP_i <= "0011";
    FZ_i <= '1';
    wait for 40 ns;
    
    

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