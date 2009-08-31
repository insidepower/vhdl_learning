-- Eg. count



-- Author:             Copyright I2R, 2007
-- Dated: 

-- Revision history:    
-- Ver.Rev      Date        Author      Comments




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.numeric_std.all;



entity cnt is
    generic (n : integer := 8);    
    port ( 
        clk         : in std_logic;
        rst         : in std_logic;

        cnt_ini     : in std_logic_vector(n-1 downto 0);    -- initial value of count
        cnt_ld      : in std_logic;                         -- load initial
        cnt_en      : in std_logic;                         -- enable count
        cnt_end     : in std_logic_vector(n-1 downto 0);    -- end value of count

        cnt_o       : out std_logic_vector(n-1 downto 0);    -- output of count
        cnt_e       : out std_logic                         -- indicator of end
        );   
end cnt;


architecture rtl of cnt is



--signals___________________________________________________

signal prw_cnt      : std_logic_vector(n-1 downto 0);
signal prwcnt_end   : std_logic;





begin



cnt_rw : process (clk, rst)
    begin
      if rst = '1' then
        prw_cnt <= (others => '0');     -- cnt_ini;
      elsif rising_edge(clk) then
        if (cnt_ld = '1' or prwcnt_end = '1') then
          prw_cnt <= cnt_ini;
        elsif (cnt_en = '1') then 
          prw_cnt <= prw_cnt + 1;
        end if;
      end if;
    end process;


    prwcnt_end <= cnt_en when (prw_cnt = cnt_end) else '0';
    
    cnt_o <= prw_cnt;
    cnt_e <= prwcnt_end;
    

end rtl;


