% function y=norm1(x)
% 
% [inprow, inpcolm, inpdept] = size(x);
% counter = 1;
% filter_num = 1;
% 
% y=zeros(inprow,inpcolm,inpdept);
% K=1;
% alpha = 1.0000e-04;
% beta = 0.7500;
% 
% for k=1:1:inpdept
%     for i=1:1:inpcolm
%         for j=1:1:inprow
%             
%             main=x(j,i,filter_num);
%             
%             if filter_num == 1 || filter_num == 2
%                 prev=0;
%                 next=x(j,i,filter_num+2);
%                % a=x(j,i,filter_num+1);
%                 result = main/((K+alpha*((main^2)+(prev^2)+(next^2)))^beta);
%             
%             elseif filter_num == 96 || filter_num == 95
%                 prev = x(j,i,filter_num-2);
%                 next = 0;
%                 %a=x(j,i,filter_num-1);
%                 result = main/((K+alpha*((main^2)+(prev^2)+(next^2)))^beta);
%                 
%             else
%             prev = x(j,i,filter_num-2);
%             next = x(j,i,filter_num+2);
%             result = main/((K+alpha*((main^2)+(prev^2)+(next^2)))^beta);
%            
%             end
%             if main == 0
%                 result = 0;
%             end
%             y(counter)=result;
%             counter = counter + 1;
%         end
%     end
%     filter_num = filter_num + 1;
% end
% 
% end

function y=norm1(x)

[inprow, inpcolm, inpdept] = size(x);
counter = 1;
filter_num = 1;

y=zeros(inprow,inpcolm,inpdept);
K=1;
alpha = 1.0000e-04;
beta = 0.7500;
windowschannel = 5;
for k=1:1:inpdept
    for i=1:1:inpcolm
        for j=1:1:inprow
            
            main=x(j,i,filter_num);
            
            if filter_num == 1
                prev=0;
                next=x(j,i,filter_num+2);
                a=x(j,i,filter_num+1);
              result = main / ((K+((alpha*((main^2)+(prev^2)+(next^2)+(a^2)))/(windowschannel)))^beta);
                %result = single(main/((K+((alpha*((main^2)+(prev^2)+(next^2)))/windowschannel))^beta));
            elseif filter_num == 96
                prev = x(j,i,filter_num-2);
                next = 0;
                a=x(j,i,filter_num-1);
              result = main / ((K+((alpha*((main^2)+(prev^2)+(next^2)+(a^2)))/(windowschannel)))^beta); %% w1(3) / (1 + 1e-4*sum(w1.^2)/5)^0.75
                %result = single(main/((K+((alpha*((main^2)+(prev^2)+(next^2)))/windowschannel))^beta));
            elseif filter_num == 2
                prev = x(j,i,filter_num-1);
                next=x(j,i,filter_num+2);
                a=x(j,i,filter_num+1);
                result = main / ((K+((alpha*((main^2)+(prev^2)+(next^2)+(a^2)))/(windowschannel)))^beta);
                %result = single(main/((K+((alpha*((main^2)+(prev^2)+(next^2)))/windowschannel))^beta));
            elseif filter_num == 95
                prev = x(j,i,filter_num-2);
                next = x(j,i,filter_num+1);
                a=x(j,i,filter_num-1);
                result = main / ((K+((alpha*((main^2)+(prev^2)+(next^2)+(a^2)))/(windowschannel)))^beta);
                %result =single(main/((K+((alpha*((main^2)+(prev^2)+(next^2)))/windowschannel))^beta));
            else
            prev = x(j,i,filter_num-2);
            next = x(j,i,filter_num+2);
           a = x(j,i,filter_num-1);
            b = x(j,i,filter_num+1);
           % result =single(main/((K+((alpha*((main^2)+(prev^2)+(next^2)+(a^2)+(b^2))/windowschannel)))^beta));
          % result = single(main/((K+((alpha*((main^2)+(prev^2)+(next^2)))/windowschannel))^beta));
          result = main / ((K+((alpha*((main^2)+(prev^2)+(next^2)+(a^2)+(b^2)))/(windowschannel)))^beta);
            end
            if main == 0
                result = 0;
            end
            y(counter)=result;
            counter = counter + 1;
        end
    end
    filter_num = filter_num + 1;
end
end