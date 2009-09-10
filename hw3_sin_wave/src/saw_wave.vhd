
--================================================================================
-- @ saw_wave @
--
--  DESC:
--  Wave pattern generator.
--  5KHz periodic wave signal:
--     1. Saw wave,
--     2. Sine wave,
--     3. Quadratue wave (Sine and Cosine).
--  Time resolution: 1000 steps for a period.

--  Amplitude resolution: 12 bits (0~4095 unsigned, or -2048 ~2047 signed)
--  Using BlockRAM to store the wave pattern, Memory structure: full 1024 points for a cycle wave

--  Design spec:
--  freq_sel => 0:5kHz, 1:10kHz
--  mode_sel => 0:1000 pts, 1:250 sampling pts
--  wave_sel => 0:saw_wave, 1:sine_wave, 2:quadrature_wave

--  spartan model: spartan 3AN, XC3S700AN, FGG484, -5
--  xilinxCoreLib generation: (read below)
--============================================================================*/
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.numeric_std.all;

entity saw_wave is
   generic (n:       integer :=10);
   port(
          clk      : in std_logic;                        --synchronous clock
          arst     : in std_logic;                        --push button, reset
          freq_sel : in std_logic;
          mode_sel : in std_logic;
          wave_sel : in std_logic_vector(1 downto 0);

          dout1000 : out std_logic_vector(11 downto 0);
          dout250  : out std_logic_vector(11 downto 0)
       );
end saw_wave;

architecture rtl of saw_wave is
   ---------- component start ----------
   component cnt
      generic (n:       integer :=10);
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

   component blkram_12bit_1024
      port (
              clka  : IN std_logic;
              addra : IN std_logic_VECTOR(9 downto 0);
              douta : OUT std_logic_VECTOR(11 downto 0);
              clkb  : IN std_logic;
              addrb : IN std_logic_VECTOR(9 downto 0);
              doutb : OUT std_logic_VECTOR(11 downto 0)
           );
   END component;

   ---------- signal start ----------
    signal cnt5khz_e : std_logic;
    signal cnt5khz_o : std_logic_vector(n-1 downto 0);
    signal cnt1000_e : std_logic;
    signal cnt1000_o : std_logic_vector(n-1 downto 0);
    signal cnt250_o : std_logic_vector(n-1 downto 0);

    signal douta  : std_logic_vector(11 downto 0);
    signal doutb  : std_logic_vector(11 downto 0);
begin

   ---------- portmap start ----------
   cnt_5khz: cnt
      generic map (n    =>n)
      --generic map (n    =>16)
      port map (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>b"00_0000_0001",
         cnt_ld         =>'0',
         cnt_en         =>'1',
         cnt_end        =>b"00_0000_1001",

         cnt_e          =>cnt5khz_e,
         cnt_o          =>cnt5khz_o
      );

   cnt1024: cnt
      generic map (n    =>10)
      --generic map (n    =>16)
      port map (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>b"00_0000_0001",
         cnt_ld         =>'0',
         cnt_en         =>cnt5khz_e,
         cnt_end        =>b"11_1110_1000", --1000

         cnt_e          =>cnt1000_e,
         cnt_o          =>cnt1000_o
      );

        blkram_1024_p: blkram_12bit_1024
        port map (
                        clka  => clk,
                        addra => cnt1000_o,
                        douta => douta,
                        clkb  => clk,
                        addrb => cnt250_o,
                        doutb => doutb
                    );

   ---------- initialization start ----------
        --dummy value
        cnt250_o <= (others => '0');

   ---------- myProcess start ----------
        saw_wave1000_p:process(clk)
        begin
			  if arst='1' then
				  dout1000 <= (others => '0');
			  elsif rising_edge(clk) then
				  dout1000 <= douta;
			  end if;
        end process;

        saw_wave250_p:process(clk)
        begin
            if arst='1' then
                dout250 <= (others => '0');
            elsif rising_edge(clk) then
					dout250 <= doutb;
            end if;
        end process;
end rtl;


--============================================================================*/
--  xilinxCoreLib generation: (read below)
-- RW method:
--    * Method 1:
--vmap the library folder as usual  ¡°vmap work work¡±.
--(for every project need to manually map the library..)
--
--    * Method 2:
--Modify ¡°modelsim.ini¡± file: add
--XilinxCoreLib = C:/Xilinx92i/ISE92i/vhdl/mti_se/XilinxCoreLib

-- Danny's method
-- 1. Open a new project in ISE (can also be an old project) 
-- 2. Under 'device properties'
-- a) Make sure board type is the same as the target board (XC3S700AN)
-- b) Synthesis Tool: XST (VHDL/Verilog)
-- c) Simulator: Modelsim-SE VHDL
-- d) Preferred Language: VHDL
-- 3. After project created, expand 'Design Utilities' under processes
-- (left middle panel) 
-- 4. Double click on 'Compile HDL Simulation Libraries'
-- 5. ... wait ...
-- 6. Once done the icon will change to a green tick. Take note of the
-- directories and libraries that were generated. Normally will be
-- $XilinxDir/vhdl/mti_se/XilinxCoreLib, $XilinxDir/vhdl/mti_se/simprim and
-- $XilinxDir/vhdl/mti_se/unisim
-- 
-- In ModelSim:
-- 7. Open your project
-- 8. Under the library tab on the left, right click in the empty area and
-- choose 'New > Library...'
-- 9. Under 'Create', choose 'map to an existing library'
-- 10. Under 'Library Maps to:', click 'Browse'
-- 11. Navigate to one of the directories that were created in step 6 12.
-- Copy the directory name as the 'Library Name' and click ok 13. Repeat
-- steps 8 to 12 for each of the 3 directories created in step 6
-- 
-- You should be able to use the dual port ram now in that project
--============================================================================*/
