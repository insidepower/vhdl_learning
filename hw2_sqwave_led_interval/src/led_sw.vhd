--@@ ucf file @@--
--NET "CLK_50M"       LOC = "E12"  | IOSTANDARD = LVCMOS33 | PERIOD = 20.000 ;
--NET "LED<0>"        LOC = "R20"  | IOSTANDARD = LVCMOS33 | DRIVE = 8 | SLEW = SLOW ;
--...
--NET "LED<7>"        LOC = "W21"  | IOSTANDARD = LVCMOS33 | DRIVE = 8 | SLEW = SLOW ;
--NET "SW<0>"         LOC = "V8"   | IOSTANDARD = LVCMOS33 ;
--...
--NET "SW<3>"         LOC = "T9"   | IOSTANDARD = LVCMOS33 ;
--NET "tst_p0"     LOC = "V14"  | IOSTANDARD = LVCMOS33 | DRIVE = 8 | SLEW = FAST ;
--NET "BTN_SOUTH"     LOC = "T15"  | IOSTANDARD = LVCMOS33 | PULLDOWN ;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.numeric_std.all;

entity led_sw is
   generic (led_cnt_bit  : integer :=8);
   --generic (led_cnt_bit  : integer :=16);
   port(
          clk_50m        : in std_logic;                        --synchronous clock
          btn_south      : in std_logic;                        --push button
          sw             : in  std_logic_vector (3 downto 0);   --dip switch

          --tst_p0         : out std_logic;                       --10 Hz square wave, 50% duty cycle
          led            : out std_logic_vector (7 downto 0)
   );
end led_sw;

architecture rtl of led_sw is

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
   signal led_dir          : std_logic;                           --led light direction
   --signal led_7downto2     : bit_vector(7 downto 2);
   signal led_7downto2     : std_logic_vector(7 downto 2);
   signal led_cnt_o1        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal led_cnt_o2        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal led_cnt_o3        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal led_cnt_o        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal led_cnt_trg1      : std_logic;                          --trigger to lit next led
   signal led_cnt_trg2      : std_logic;                          --trigger to lit next led
   signal led_cnt_trg3      : std_logic;                          --trigger to lit next led
   signal led_cnt_trg      : std_logic;                          --trigger to lit next led
   --output
   signal arst             : std_logic;                          
   --signal led_cnt_init     : std_logic_vector(led_cnt_bit-1 downto 0);     --led counter initial value
   signal led_cnt_ld       : std_logic;                          --led counter load signal
   --signal led_cnt_en       : std_logic;                          --led counter enable
   --signal led_cnt_end      : std_logic_vector(led_cnt_bit-1 downto 0);     --led counter end/last value

begin

   clk <= clk_50m;

   -----------------------------------------------------------------------------
   --assignment 1
   --a.   SW[0], SW[1] both on, LED[0] light;
   --b.   LED[1] is indicated, when SW[0] and SW[1] are different.
   -----------------------------------------------------------------------------
   led(0) <= '1' when (sw(0) and sw(1))='1' else '0';
   led(1) <= '1' when (sw(0) xor sw(1))='1' else '0';
   --led(7 downto 2) <= (others => '1');

   -----------------------------------------------------------------------------
   --assignment 3
   --a.    LED[7:2] turn on in sequence, interval time 0.4s: LED[2] -> LED[3]
   --    -> LED [4].. LED [7] -> LED[2] -> ¡­ LED [7], repeated in
   --    periodically. (SW[3]=¡¯0¡¯)
   --b.    SW[3] = ¡®1¡¯ change the LED light sequence, LED[7] -> LED[6] ¡­
   --CALCULATION: 0.4s=2.5Hz; 50MHz/2.5Hz=20`000`000 (2M*2^5 => 32M)
   -----------------------------------------------------------------------------
   arst <= '1' when (sw(0)='0' and sw(1)='0') else '0';
   led_cnt_ld <= '1' when arst = '1' else '0';
   led_dir <= sw(3);

   led_cnt1: cnt
      generic map (n    =>led_cnt_bit)
      --generic map (n    =>16)
      port map
      (  
         clk            =>clk,
         --clk            =>clk_50m,
         rst            =>arst,

         cnt_ini        =>x"01",
         --cnt_ini        =>led_cnt_init,
         --cnt_ld         =>led_cnt_ld,
         cnt_ld         =>'0',
         cnt_en         =>'1',
         cnt_end        =>x"FA",  --250d
         --cnt_end        =>x"0131_2D00",  --20M

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

         cnt_e          =>led_cnt_trg2,
         cnt_o          =>led_cnt_o2
      );

   led_cnt3: cnt
      generic map (n    =>led_cnt_bit)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>led_cnt_trg2,
         cnt_end        =>x"14",  --20d

         cnt_e          =>led_cnt_trg3,
         cnt_o          =>led_cnt_o3
      );

   led_cnt4: cnt
      generic map (n    =>led_cnt_bit)
      port map
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>led_cnt_trg3,
         cnt_end        =>x"10",  --16d

         cnt_e          =>led_cnt_trg,
         cnt_o          =>led_cnt_o
      );

   led_cnt: process (clk, arst)
   begin
      if arst = '1' then
         --led_cnt_init <= (others => '0');
         --led_cnt_ld <= '1';
         led_7downto2 <= "100000";
         --led_7downto2 <= (0 =>'1', others => '0'); --LSB=1
      elsif rising_edge(clk) then
         if led_cnt_trg = '1' then
            if led_dir = '0' then      --increasing pattern
               --KIV: try without rem
               --led_7downto2 <= (led_7downto2 * 2) rem 36;
               --led_7downto2 <= led_7downto2 rol 1;
               led_7downto2 <= led_7downto2(6 downto 2) & led_7downto2(7) ;
            else                       --decreasing pattern
               --led_7downto2 <= led_7downto2 ror 1;
               led_7downto2 <= led_7downto2(2) & led_7downto2(7 downto 3);
            end if;
         end if;
      end if;
   end process;

   --led(7 downto 2) <= to_stdlogicvector(led_7downto2);
   led(7 downto 2) <= led_7downto2;

end rtl;
