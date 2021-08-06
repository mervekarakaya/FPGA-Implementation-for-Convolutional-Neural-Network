function y = padd(M,N)

[Mrow, Mcol, Mdepth] = size(M); %M size =13*13*256

Mrow = Mrow + (2*N); %Padding = 1 ; Mrow=15
Mcol = Mcol + (2*N); %Padding = 1 ; Mcol=15

k=1;
depth=1;
result = zeros(Mrow,(Mdepth*Mcol));
    for i=Mrow:Mrow:(Mdepth*Mcol)
        M1 = M(:,:,depth);
        depth=depth+1;
        if N > 0
            M1(end+2*N,end+2*N) = 0 ;
            result(1:Mrow,k:i) = M1([end-N+1:end 1:end-N], [end-N+1:end 1:end-N]);
        end
        k=k+Mrow;
    end
y = result;
y = reshape(y,[Mrow Mcol Mdepth]);
end