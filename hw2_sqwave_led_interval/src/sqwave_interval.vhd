-----------------------------------------------------------------------------
--bonus: question 2
--5)    Use SW[1:0] to select one of 100Hz, 10Hz, 5Hz and 2Hz signals,
--output selected signal to the I/O pin.
--Use SW[1:0] to select LED[7:2] light interval time for 0.4s, 0.25s, 0.1s and 0.05s.
--SW: sec=frez
--00:2Hz     ;
--01:5Hz    ;
--10:10Hz     ;
--11:100Hz
--btn_south to reset
-----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.numeric_std.all;

entity sqwave_interval is
   generic (led_cnt_bit  : integer :=8);
   --generic (led_cnt_bit  : integer :=16);
   port(
          clk_50m        : in std_logic;                        --synchronous clock
          btn_south      : in std_logic;                        --push button
          sw             : in  std_logic_vector (3 downto 0);   --dip switch

          tst_p0         : out std_logic;                       --10 Hz square wave, 50% duty cycle
          led            : out std_logic_vector (7 downto 0)
   );
end sqwave_interval;

architecture rtl of sqwave_interval is

   ---------- component start ----------
   component cnt
      generic (n:       integer :=8);
      port (
              clk            : in std_logic;
              rst            : in std_logic;

              cnt_ini        : in std_logic_vector(n-1 downto 0);   --initial value of counter
              cnt_ld         : in std_logic;                        --load initial
              cnt_en         : in std_logic;                        --enable count
              cnt_end        : in std_logic_vector(n-1 downto 0);   --end value of count

              cnt_o          : out std_logic_vector(n-1 downto 0);  --output of count
              cnt_e          : out std_logic                        --indicator of end
           );
   end component;

   ---------- signal start ----------
   --input
   signal clk              : std_logic;
   signal led_sw1dn0       : std_logic_vector(1 downto 0);
   signal led_dir          : std_logic;                           --led light direction
   signal led_7downto2     : std_logic_vector(7 downto 2) := "000000";
   signal led_cnt_o1        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal led_cnt_o2        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal led_cnt_o3        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal led_cnt_o4        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal led_cnt_o5        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal led_cnt_o6        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal led_cnt_trg1      : std_logic;                          --trigger to lit next led
   signal led_cnt_trg2      : std_logic;                          --trigger to lit next led
   signal led_cnt_trg3      : std_logic;                          --trigger to lit next led
   signal led_cnt_trg4      : std_logic;                          --trigger to lit next led
   signal led_cnt_trg5      : std_logic;                          --trigger to lit next led
   signal led_cnt_trg6      : std_logic;                          --trigger to lit next led
   signal sqwave100_trg      : std_logic;                        
   signal sqwave10_trg      : std_logic;                          
   signal sqwave5_trg      : std_logic;                          
   signal sqwave2_trg      : std_logic;                         
   signal sqwave100_o      : std_logic_vector(led_cnt_bit-1 downto 0);   
   signal sqwave10_o      : std_logic_vector(led_cnt_bit-1 downto 0);   
   signal sqwave5_o      : std_logic_vector(led_cnt_bit-1 downto 0);   
   signal sqwave2_o      : std_logic_vector(led_cnt_bit-1 downto 0);  
   signal sqwave_o      : std_logic;                         
   signal led_trg           : std_logic;
   signal sqwave_trg           : std_logic;
   --output
   signal arst             : std_logic;                          
   signal led_cnt_ld       : std_logic;                          --led counter load signal

begin

   led_cnt1: cnt
      generic map (n    =>led_cnt_bit)
      --generic map (n    =>16)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>'1',
         cnt_end        =>x"FA",  --250d
         --cnt_end        =>x"03",

         cnt_e          =>led_cnt_trg1,
         cnt_o          =>led_cnt_o1
      );

   led_cnt2: cnt
      generic map (n    =>led_cnt_bit)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>led_cnt_trg1,
         cnt_end        =>x"FA",  --250d
         --cnt_end        =>x"03",  

         cnt_e          =>led_cnt_trg2,
         cnt_o          =>led_cnt_o2
      );

   led_cnt3: cnt
      --20Hz:  50m/20Hz/250/250=40
      generic map (n    =>led_cnt_bit)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>led_cnt_trg2,
         cnt_end        =>x"28",  --40d
         --cnt_end        =>x"02",  

         cnt_e          =>led_cnt_trg3,
         cnt_o          =>led_cnt_o3
      );

   led_cnt4: cnt
      --2.5Hz:  50m/2.5Hz/250/250/40=8
      generic map (n    =>led_cnt_bit)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>led_cnt_trg3,
         cnt_end        =>x"08",  --8d

         cnt_e          =>led_cnt_trg4,
         cnt_o          =>led_cnt_o4
      );

   led_cnt5: cnt
      --4Hz:  50m/4Hz/250/250=200
      generic map (n    =>led_cnt_bit)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>led_cnt_trg2,
         cnt_end        =>x"C8",  --200d
         --cnt_end        =>x"09",  

         cnt_e          =>led_cnt_trg5,
         cnt_o          =>led_cnt_o5
      );

   led_cnt6: cnt
      --10Hz:  50m/10Hz/250/250=80
      generic map (n    =>led_cnt_bit)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>led_cnt_trg2,
         cnt_end        =>x"50",  --80d

         cnt_e          =>led_cnt_trg6,
         cnt_o          =>led_cnt_o6
      );

      sw_cnt100Hz: cnt
      --100Hz: 50m/100Hz/250/250/80(led_cnt6)=10
      generic map (n    =>led_cnt_bit)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>led_cnt_trg6,
         cnt_end        =>x"0A",  --10d

         cnt_e          =>sqwave100_trg,
         cnt_o          =>sqwave100_o
      );

      sw_cnt5Hz: cnt
      --5Hz: 10Hz/5=2
      generic map (n    =>led_cnt_bit)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>led_cnt_trg6,
         cnt_end        =>x"02",  --2d

         cnt_e          =>sqwave5_trg,
         cnt_o          =>sqwave5_o
      );

      sw_cnt2Hz: cnt
      --2Hz: 10Hz/2=5
      generic map (n    =>led_cnt_bit)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         --2Hz
         cnt_en         =>led_cnt_trg6,
         cnt_end        =>x"05",  --2d
         --testing: 20MHz sqwave (half=10MHz)
         --cnt_en         =>'1',
         --cnt_end        =>x"05",

         cnt_e          =>sqwave2_trg,
         cnt_o          =>sqwave2_o

      );

   clk <= clk_50m;
   arst <= '1' when (btn_south='1') else '0';
   led_cnt_ld <= '1' when arst = '1' else '0';
   led_dir <= sw(3);
   led_sw1dn0 <= sw(1 downto 0);

   led_cnt_p: process (clk)
   begin
      if rising_edge(clk) then
         if (led_cnt_trg3='1' and sw(1)='1' and sw(0)='1') then
             --20Hz
             led_trg<='1';
         elsif led_cnt_trg4='1' and sw(1)='0' and sw(0)='0' then
             --2.5Hz
             led_trg<='1';
         elsif led_cnt_trg5='1' and sw(1)='0' and sw(0)='1' then
             --4Hz
             led_trg<='1';
         elsif led_cnt_trg6='1' and sw(1)='1' and sw(0)='0' then
             --10Hz
             led_trg<='1';
         else
             led_trg<='0';
         end if;
      end if;
   end process;

   trigger_led: process(clk, arst)
   begin
      if arst = '1' then
         led_7downto2 <= "000001";
      elsif rising_edge(clk) then
         if led_trg='1' then
            if led_dir = '0' then --increasing pattern
               led_7downto2 <= led_7downto2(6 downto 2) & led_7downto2(7);
            else
               led_7downto2 <= led_7downto2(2) & led_7downto2(7 downto 3);
            end if;
         end if;
      end if;
   end process;

   sqwave_p: process(clk, sw)
   begin
      if rising_edge(clk) then
         case sw(1 downto 0) is
            when "11" => sqwave_trg <= sqwave100_trg;
            when "10" => sqwave_trg <= sqwave10_trg;
            when "01" => sqwave_trg <= sqwave5_trg;
            when "00" => sqwave_trg <= sqwave2_trg;
            when others => sqwave_trg <= '0';
         end case;
      end if;
   end process;

   trigger_sqwave: process(clk, arst)
   begin
       if arst = '1' then
           sqwave_o <= '0';
       elsif rising_edge(clk) then
           if sqwave_trg ='1' then
               sqwave_o <= not sqwave_o;
           end if;
       end if;
   end process;

   --led_7downto2 <= "000001" when arst='1' else
   --                led_7downto2(6 downto 2) & led_7downto2(7) when (led_dir='0' and led_trg='1') else --increasing pattern
   --                led_7downto2(2) & led_7downto2(7 downto 3) when (led_dir='1' and led_trg='1') else --decreasing pattern
   --                led_7downto2;

   tst_p0 <= sqwave_o;
   sqwave10_trg <= led_cnt_trg6;   --tie together since they have same frequency
   sqwave10_o <= led_cnt_o6;
   led(7 downto 2) <= led_7downto2;
   led(1) <= '1' when (sw(0) xor sw(1))='1' else '0';
   led(0) <= '1' when (sw(0) and sw(1))='1' else '0';

end rtl;
