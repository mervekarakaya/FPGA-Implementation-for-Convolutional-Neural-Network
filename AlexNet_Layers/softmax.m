function y = softmax(x)
    y_matrix = zeros(1,1,1000);
    
    ex1 = sum(exp(x));
    for i = 1 : 1 : 1000
        ex2=exp(x);
        y_matrix(:,:,i) = ex2(i)/ex1;
        
    end
  y = y_matrix;
end