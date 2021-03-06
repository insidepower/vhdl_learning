-----------------------------------------------------------------------------
--bonus: question 1
--Use SW[1:0] to select LED[7:2] light interval time for 0.4s, 0.25s, 0.1s and 0.05s.
--SW=00:.4s=2.5Hz     ;01:.25s=4Hz    ;10:.1s=10Hz     ;11:0.05s=20Hz
--btn_south to reset
-----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.numeric_std.all;

entity led_sw_interval is
   generic (led_cnt_bit  : integer :=8);
   --generic (led_cnt_bit  : integer :=16);
   port(
          clk_50m        : in std_logic;                        --synchronous clock
          btn_south      : in std_logic;                        --push button
          sw             : in  std_logic_vector (3 downto 0);   --dip switch

          tst_p0         : out std_logic;                       --10 Hz square wave, 50% duty cycle
          led            : out std_logic_vector (7 downto 0)
   );
end led_sw_interval;

architecture rtl of led_sw_interval is

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
   signal led_7downto2     : std_logic_vector(7 downto 2);
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
   signal led_trg           : std_logic;
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
         --cnt_end        =>x"FA",  --250d
         cnt_end        =>x"20",  --250d

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
         --cnt_end        =>x"FA",  --250d
         cnt_end        =>x"20",  --250d

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

   clk <= clk_50m;
   arst <= '1' when (btn_south='1') else '0';
   led_cnt_ld <= '1' when arst = '1' else '0';
   led_dir <= sw(3);
   led_sw1dn0 <= sw(1 downto 0);


   led_cnt_p: process (clk, arst)
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

   led_7downto2 <= (others => '0') when arst='1' else
                   led_7downto2(6 downto 2) & led_7downto2(7) when (led_dir='0' and led_trg='1') else --increasing pattern
                   led_7downto2(2) & led_7downto2(7 downto 3) when (led_dir='1' and led_trg='1') else --decreasing pattern
                   led_7downto2;

   led(7 downto 2) <= led_7downto2;
   led(1 downto 0) <= "00";

end rtl;
