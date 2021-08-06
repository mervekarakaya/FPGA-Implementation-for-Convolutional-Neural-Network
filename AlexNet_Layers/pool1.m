function y = pool1(x,w)

[wrow, wcol] = size(w); % kernel
[xrow,xcol] = size(x);

yrow = ((xrow-wrow)/2)+1; % outpot row (2 stride)
ycol = ((xcol-wcol)/2)+1;
shift_row =((xrow-wrow)+1); % ne kadar kaydýracaðým
shift_col =((xcol-wcol)+1);

y=zeros(yrow, ycol); % output
counter=1;

for k = 1:2:shift_row
    for m = 1:2:shift_col
        t = x(m:wrow,k:wcol);
        f = max(max(t));
        y(counter)=f;
        wrow = wrow+2;
        counter=counter+1;
    end
    wcol=wcol+2;
    wrow=3;
end

end
