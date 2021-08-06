function y = conv3(x,w)

[wrow, wcol] = size(w); % kernel
[xrow, xcol] = size(x); % image

yrow = ((xrow-wrow)/1)+1; % outpot row (1 stride)
ycol = ((xcol-wcol)/1)+1;
shitf_row =((xrow-wrow)+1); 
shift_col =((xcol-wcol)+1); 

y=(zeros(yrow, ycol)); % output
k=1;
for j = 1 : 1 : shitf_row
    for i = 1 : 1 : shift_col
        a=x(i:wrow,j:wcol);
       matrix_sum=(sum(sum(a.*w)));
        y(k)=matrix_sum;
        wrow=wrow+1;
        k=k+1;
    end
    wcol=wcol+1;
    wrow=3;
end
end
