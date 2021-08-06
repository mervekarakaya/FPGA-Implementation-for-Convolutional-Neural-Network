
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;


--package my_data_type is
--type image_matrix_1 is array(1 to 227, 1 to 227) of sfixed(8 downto 0);
--type filter_matrix_1 is array(1 to 11, 1 to 11) of sfixed(9 downto -6);
--type conv_matrix_1 is array(1 to 55, 1 to 55) of sfixed(9 downto -6);
--end package;

--use work.my_data_type.all;
use work.conv.all;

entity main is
    port(input_image : in image_matrix;
        input_filter : in filter_matrix;
        output_image : out conv_matrix);
    end main;

architecture Behavioral of main is

--signal image  : image_matrix; --227x227
--signal filter : filter_matrix; --11x11
--signal conv   : conv_matrix; --55x55

begin
--output_image <= conv;
output_image <= convolution(input_image, input_filter);

end Behavioral;