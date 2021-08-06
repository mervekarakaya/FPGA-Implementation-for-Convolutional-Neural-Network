function y = conv1(x,w)

[wrow, wcol] = size(w); % kernel
[xrow, xcol] = size(x); % image

yrow = ((xrow-wrow)/4)+1; % outpot row (4 stride)
ycol = ((xcol-wcol)/4)+1;
shitf_row =((xrow-wrow)+1); % ne kadar kaydýracaðým
shift_col =((xcol-wcol)+1); 

y=(zeros(yrow, ycol)); % output
k=1;
for j = 1 : 4 : shitf_row
    for i = 1 : 4 : shift_col
        a=x(i:wrow,j:wcol);
       matrix_sum=(sum(sum(a.*w)));
        y(k)=matrix_sum;
        wrow=wrow+4;
        k=k+1;
    end
    wcol=wcol+4;
    wrow=11;
end
end