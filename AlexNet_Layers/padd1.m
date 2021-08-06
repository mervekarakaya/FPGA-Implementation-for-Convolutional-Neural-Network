function M = padd1(M,N)
k=1;
depth=1;
result = zeros(31,2976);
    for i=31:31:2976
        M1 = M(:,:,depth);
        depth=depth+1;
        if N > 0
            M1(end+2*N,end+2*N) = 0 ;
            result(1:31,k:i) = M1([end-N+1:end 1:end-N], [end-N+1:end 1:end-N]);
        end
        k=k+31;
    end
M = result;
M = reshape(M,[31 31 96]);
end