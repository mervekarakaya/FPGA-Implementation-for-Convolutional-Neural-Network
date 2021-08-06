counter_true = 0;
counter_false = 0;
for k=1:1:1000
    for i=1:1:1
        for j=1:1:1
           a= softmx (j,i,k)- softmx_act(j,i,k);
           if a>10e-5 && a>0
                 counter_false =  counter_false + 1;
         
           elseif a<0 && a<-10e-5
              counter_false =  counter_false + 1;
           else
               counter_true = counter_true +1;
           end
        end
    end
end
