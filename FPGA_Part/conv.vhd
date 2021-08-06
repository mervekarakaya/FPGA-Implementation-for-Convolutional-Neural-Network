library IEEE;
use ieee.fixed_pkg.all;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package conv is

type image_matrix is array(1 to 5, 1 to 5) of sfixed(8 downto 0);
--signal image : image_matrix;

type filter_matrix is array(1 to 3, 1 to 3) of sfixed(3 downto 0);
--signal filter : filter_matrix;

type conv_matrix is array(1 to 3, 1 to 3) of sfixed(6 downto -3);
--signal conv_image : conv_matrix;

function convolution (signal image : image_matrix ; signal filter : filter_matrix) return conv_matrix;

end conv;

package body conv is

function convolution (signal image : image_matrix ; signal filter : filter_matrix) return conv_matrix is
variable conv_image : conv_matrix;

variable idx_step  : natural :=1;      
variable pre_sum   : sfixed(12 downto -6):="0000000000000000000";
variable sum       : sfixed(12 downto -6):="0000000000000000000";
variable irow      : natural :=1;
variable icol      : natural :=1;
variable irow2     : natural :=3;
variable icol2     : natural :=3;
variable trow      : natural :=1;
variable tcol      : natural :=1;
variable row_index : natural :=1;
variable col_index : natural :=1;
--variable temp_sum  :sfixed(57 downto -6);


type temp_matrix is array(1 to 3, 1 to 3) of sfixed(9 downto -6);
variable temp : temp_matrix;

begin

-- for row in idx_step to 217 loop
--		for column in idx_step to 217 loop
--	temp :=image(row to wrow,column to wcol);
	for image_indx in 1 to 9 loop --55*55
	
		--11x11 image
		  for i in irow to irow2 loop
		      for j in icol to icol2 loop
		 temp(trow,tcol) := image(i,j);
		 if (tcol = 11) then
		 tcol := 1;
		 else
		 tcol :=tcol + 1;
		 end if;
		      end loop;
		      trow := trow + 1;
		      tcol := 1;
		 end loop;
		      trow := 1;
		      tcol := 1;
		      
		  
		     
		--Multipication process
			for index_row in 1 to 3 loop--11
				for index_column in 1 to 3 loop--11
		pre_sum := resize(temp(index_row,index_column) * filter(index_row,index_column),12,-6);
		sum := resize(sum+pre_sum,12,-6);
				end loop;
			end loop;
	conv_image(row_index,col_index) := sum;
	
				if (col_index = 3) then--11
				row_index := row_index + 1;
				col_index := 1;
				else
				col_index := col_index + 1;
				end if;
				
				if(icol2 = 5) then
				icol2 := 3;
				icol  := 1;
				irow := irow + 1;-- stride +4
				irow2 := irow2 + 1;--
				else
				icol := icol + 1;--
                icol2 := icol2 + 1;--
                end if;
                

		end loop;
--end loop;

        return conv_image;
 end convolution;
end conv;
