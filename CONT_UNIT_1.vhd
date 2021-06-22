library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CONT_UNIT_1 is
  Generic (COP_WIDTH: integer:= 4;
           CW_WIDTH: integer:= 10);
  Port (CLK_i: in STD_LOGIC;
        RST_i: in STD_LOGIC;
        COP_i: in STD_LOGIC_VECTOR (COP_WIDTH-1 downto 0);
        FZ_i: in STD_LOGIC;
        CW_o: out STD_LOGIC_VECTOR (CW_WIDTH-1 downto 0));
end CONT_UNIT_1;

architecture Behavioral of CONT_UNIT_1 is

                        --Estados

    type ESTADOS is (IDLE, LOAD, DECO, OPE_A, ADDR_A, ADDR_B, OPE_B, MOV_B, A_ADD_B, A_CMP_B, BRANCH, BRANCH_INST, ESPERA);
    signal SIG_ESTADO: ESTADOS;

                        --Salidas

    constant OUTPUT_ESPERA: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=         "0000000000";
    constant OUTPUT_IDLE: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=           "0000000000";
    constant OUTPUT_LOAD: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=           "0010010000";
    constant OUTPUT_DECO: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=           "0000000000";
    constant OUTPUT_OPE_A: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=          "0000000001";
    constant OUTPUT_ADDR_A: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=         "0001000000";
    constant OUTPUT_OPE_B: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=          "0000000010";
    constant OUTPUT_ADDR_B: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=         "0001100000";
    constant OUTPUT_MOV_B: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=          "1001001100";
    constant OUTPUT_A_ADD_B: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=        "0101101100";
    constant OUTPUT_A_CMP_B: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=        "1100000100";
    constant OUTPUT_BRANCH: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=         "0001100000";
    constant OUTPUT_BRANCH_INST: STD_LOGIC_VECTOR(CW_WIDTH-1 downto 0) :=    "0011110000";

begin

process (CLK_i, RST_i)
begin
    if RST_i = '1' then
        SIG_ESTADO <= IDLE;
    elsif rising_edge(CLK_i)then
        case SIG_ESTADO is
            when IDLE=>
                SIG_ESTADO <= LOAD;
            when LOAD =>
                SIG_ESTADO <= DECO;
            when DECO =>
                if COP_i = "0011" then
                    if FZ_i = '0' then
                        SIG_ESTADO <= LOAD;
                    else
                        SIG_ESTADO <= BRANCH;
                    end if;
                else
                    SIG_ESTADO <= ADDR_B;
                end if;
            when BRANCH =>
                SIG_ESTADO <= BRANCH_INST;
            when BRANCH_INST =>
                SIG_ESTADO <= DECO;
            when ADDR_B =>
                SIG_ESTADO <= OPE_B;
            when OPE_B =>
                    SIG_ESTADO <= ADDR_A;  
            when ADDR_A =>
                if COP_i = "0000" then
                    SIG_ESTADO <= MOV_B; 
                else
                    SIG_ESTADO <= OPE_A;
                end if;   
            when MOV_B =>
                SIG_ESTADO <= ESPERA;         
            when OPE_A =>
                if COP_i = "0010"  then
                   SIG_ESTADO <= A_CMP_B;
                else
                   SIG_ESTADO <= A_ADD_B;
                end if;
            when A_CMP_B =>
                SIG_ESTADO <= ESPERA;
            when A_ADD_B =>
                SIG_ESTADO <= ESPERA;
            when ESPERA =>
                SIG_ESTADO <= LOAD;
        end case;
    end if;
end process;

with SIG_ESTADO select
CW_o <= OUTPUT_IDLE when IDLE,
        OUTPUT_LOAD when LOAD,
        OUTPUT_DECO when DECO,
        OUTPUT_OPE_A when OPE_A,
        OUTPUT_ADDR_A when ADDR_A,
        OUTPUT_OPE_B when OPE_B,
        OUTPUT_ADDR_B when ADDR_B,
        OUTPUT_MOV_B when MOV_B,
        OUTPUT_A_ADD_B when A_ADD_B,
        OUTPUT_A_CMP_B when A_CMP_B,
        OUTPUT_BRANCH when BRANCH,
        OUTPUT_BRANCH_INST when BRANCH_INST,
        OUTPUT_IDLE when others;

end Behavioral;
