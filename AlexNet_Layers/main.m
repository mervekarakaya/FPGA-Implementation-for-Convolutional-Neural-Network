%% --------------------------------------------------------------------------------
image=imread('nar.jpg');%original image
image=imresize(image,[227 227]);
image_1=single(image);
net=alexnet();
image_mean = net.Layers(1).Mean();
image_1=image_1-image_mean;

% create convolution bias values
%% ----------------------------------------------------------------------------------
%create convolution1 filter
conv1_filter = single(zeros(11,11*3*96));
depth=1;
filternumber=1;
i=1;
for j=11:11:3168  %% 3168 = 11*3*96
    
    conv1_filter(1:11,i:j) = net.Layers(2).Weights(:,:,depth,filternumber);
    i=i+11;
    if depth==3
        depth=1;
        filternumber=filternumber +1;
    else
        depth=depth+1;
    end
end

conv1_filter = reshape(conv1_filter,[11 11 3 96]);

%% ---------------------------------------------------------------------------------------------
%convolution1 process

convolution_result = single(zeros(55,5280)); %55*96
convolution_preresult =single(zeros(55));
rgb = 1;
conv_filternumber =1;
conv1_bias=net.Layers(2).Bias();
row=1;
colm=55;
bias = 1;

for i=1:1:288 %96*3
    
    convolution_preresult = single(conv1(image_1(:,:,rgb),conv1_filter(:,:,rgb,conv_filternumber)));
    convolution_result(1:55,row:colm) = convolution_preresult + convolution_result(1:55,row:colm);
    
    
    if rgb==3
        rgb = 1;
       conv_filternumber = conv_filternumber + 1;
       convolution_result(1:55,row:colm) =  convolution_result(1:55,row:colm) + conv1_bias(bias);
       bias = bias  + 1;
       row = row + 55;
       colm = colm + 55;
     
    else 
        rgb = rgb + 1;
    end
    
end

convolution_result = reshape(convolution_result,[55 55 96]); % Layer2 output
%% --------------------------------------------------------------------------------------------
%ReLu
relu=ReLu(convolution_result); % Layer3 output
relu_1 = activations(net,image_1+image_mean,'relu1');
%% ----------------------------------------------------------------------------------------------
%normalization
%norm_1 = activations(net,image1+image_mean,'norm1');
norm_1=single(norm1(relu));
%% ------------------------------------------------------------------------------------------------
%maxpool1 process

maxpool_pre_result = zeros(27,2592);
maxpool_depth=1;
w=1;
for i = 27:27:2592
    max_poll_filter=[0 0 0;0 0 0;0 0 0];
    maxpool_pre_result(1:27,w:i)=single(pool1(norm_1(:,:,maxpool_depth),max_poll_filter)); %Layer5 output
    w=w+27;
    maxpool_depth = maxpool_depth + 1;
    
end

max_pool_result =single(reshape(maxpool_pre_result,[27 27 96])); %Layer5 output
%% ------------------------------------------------------------------------------------------------
% group1 conv padding
padding = single(padd(max_pool_result,2));

%group convolution filters
group_conv2_filter1 = single(zeros(5,5*48*256));
depth=1;
filternumber=1;
i=1;
group=1;
for j=5:5:61440  %% 61440 = 5*48*256
    
    group_conv2_filter1(1:5,i:j) = net.Layers(6).Weights(:,:,depth,filternumber,group);
    i=i+5;
    
    if (filternumber == 128 && depth ==48)
        depth = 1;
        filternumber = 1;
        group=2;
        
    elseif depth==48
        depth=1;
        filternumber=filternumber +1;
        
    else
        depth = depth+1;
    end
end

group_conv2_filter1 = reshape(group_conv2_filter1,[5 5 48 256]);
    
%% -------------------------------------------------------------------------------------------------------
% group2 conv process1
depth = 1;
group_conv2_result = single(zeros(27,3456)); % 27*128
group_conv2_preresult = zeros(27);
group_conv2_bias = net.Layers(6).Bias();
group_conv2_filternumber = 1;
result_row1 = 1;
result_colm1 = 27;
%result_row = 1;
%result_colm = 27;
bias = 1;
for i=1:1:6144 %48*128
    
    group_conv2_preresult = single(grouped_conv(padding(:,:,depth),group_conv2_filter1(:,:,depth,group_conv2_filternumber)));
    group_conv2_result(1:27,result_row1:result_colm1) = group_conv2_preresult + group_conv2_result(1:27,result_row1:result_colm1);
    if depth == 48
        depth = 1;
        group_conv2_filternumber = group_conv2_filternumber + 1;
         group_conv2_result(1:27,result_row1:result_colm1) = group_conv2_result(1:27,result_row1:result_colm1) + group_conv2_bias(bias);
         result_row1 =  result_row1 + 27;
        result_colm1 = result_colm1 + 27;
        bias = bias +1;
    else
        depth = depth + 1;
    end  
    
end

group_conv2_result = reshape(group_conv2_result,[27 27 128]); %group1 conv output

%% -------------------------------------------------------------------------------------------------------
% group2 conv process2
depth = 49;
filter_depth = 1;
group_conv2_result2 = single(zeros(27,3456)); % 27*128
group_conv2_preresult2 = zeros(27);
group_conv2_filternumber = 129;
result_row1 = 1;
result_colm1 = 27;
result_row = 1;
result_colm = 27;
bias = 129;

for i=1:1:6144
    
    group_conv2_preresult2(1:27,result_row:result_colm) = single(grouped_conv(padding(:,:,depth),group_conv2_filter1(:,:,filter_depth,group_conv2_filternumber)));
    group_conv2_result2(1:27,result_row1:result_colm1) = group_conv2_preresult2(1:27,result_row:result_colm) + group_conv2_result2(1:27,result_row1:result_colm1);
    if depth == 96
        depth = 49;
        filter_depth = 1;
        group_conv2_filternumber = group_conv2_filternumber + 1;
         group_conv2_result2(1:27,result_row1:result_colm1) = group_conv2_result2(1:27,result_row1:result_colm1) + group_conv2_bias(bias);
         result_row1 =  result_row1 + 27;
        result_colm1 = result_colm1 + 27;
        bias = bias +1;
    else
        depth = depth + 1;
        filter_depth = filter_depth + 1;
    end
    
end

group_conv2_result2 = reshape(group_conv2_result2,[27 27 128]);

conv2_result = cat(256,group_conv2_result,group_conv2_result2);
conv2_result = reshape(conv2_result,[27 27 256]);
%% -------------------------------------------------------------------------------------------------------
relu2 = ReLu(conv2_result);
%% -------------------------------------------------------------------------------------------------------
%normalization2
norm_2 = single(norm2(relu2));
norm_act = activations(net,image_1+image_mean,'norm2');
%% ---------------------------------------------------------------------------------------------------------
%pool2
maxpool2_pre_result = zeros(13,3328);
maxpool_depth=1;
w=1;

for i = 13:13:3328 %13*256
    max_poll_filter=[0 0 0;0 0 0;0 0 0];
    maxpool2_pre_result(1:13,w:i)=single(pool1(norm_2(:,:,maxpool_depth),max_poll_filter));
    w=w+13;
    maxpool_depth = maxpool_depth + 1;
    
end

max_pool2_result =single(reshape(maxpool2_pre_result,[13 13 256])); %Layer9 output
%% -------------------------------------------------------------------------------------------------------------------
conv3_padding=single(padd(max_pool2_result,1)); %Layer10 Padding
%% -------------------------------------------------------------------------------------------------------
%create convolution3 filter
conv3_filter = single(zeros(3,3*256*384));
depth=1;
filternumber=1;
i=1;
for j=3:3:294912  %% 294912 = 3*256*384
    
    conv3_filter(1:3,i:j) = net.Layers(10).Weights(:,:,depth,filternumber);
    i=i+3;
    if depth==256
        depth=1;
        filternumber=filternumber +1;
    else
        depth=depth+1;
    end
end

conv3_filter = reshape(conv3_filter,[3 3 256 384]);
%% -------------------------------------------------------------------------------------------------------
%convolution3 process

convolution3_result = single(zeros(13,4992)); %13*384(result*filternumber)
convolution3_preresult =single(zeros(13));
depth3 = 1;
conv3_filternumber =1;
conv3_bias=net.Layers(10).Bias();
row3=1;
colm3=13;
bias3 = 1;

for i=1:1:98304 %256*384(depth*filternumber)
    
    convolution3_preresult = single(conv3(conv3_padding(:,:,depth3),conv3_filter(:,:,depth3,conv3_filternumber)));
    convolution3_result(1:13,row3:colm3) = convolution3_preresult + convolution3_result(1:13,row3:colm3);
    
    
    if depth3==256
        depth3 = 1;
       convolution3_result(1:13,row3:colm3) =  convolution3_result(1:13,row3:colm3) + conv3_bias(bias3);
       bias3 = bias3  + 1;
       row3 = row3 + 13;
       colm3 = colm3 + 13;
       conv3_filternumber = conv3_filternumber + 1;
    else 
        depth3 = depth3 + 1;
    end
    
end

convolution3_result = reshape(convolution3_result,[13 13 384]); % Layer10 output
%% -------------------------------------------------------------------------------------------------------
relu3 = ReLu(convolution3_result); %Layer11 output
%% -------------------------------------------------------------------------------------------------------
conv4_padding = single(padd(relu3,1));
%group2 convolution filters
group_conv4_filter1 = single(zeros(3,3*192*384));
depth=1;
filternumber=1;
i=1;
group=1;
for j=3:3:221184 % 221184 = 3*192*384
    
    group_conv4_filter1(1:3,i:j) = net.Layers(12).Weights(:,:,depth,filternumber,group);
    i=i+3;
    
    if (filternumber == 192 && depth ==192)
        depth = 1;
        filternumber = 1;
        group=2;
        
    elseif depth==192
        depth=1;
        filternumber=filternumber +1;
        
    else
        depth = depth+1;
    end
end

group_conv4_filter1 = reshape(group_conv4_filter1,[3 3 192 384]);
%% ------------------------------------------------------------------------------------------------------
% group1 conv4 process1
depth = 1;
group_conv4_result = single(zeros(13,2496)); % 13*192
group_conv4_preresult = zeros(13);
group_conv4_bias = net.Layers(12).Bias();
group_conv4_filternumber = 1;
result_row1 = 1;
result_colm1 = 13;
%result_row = 1;
%result_colm = 27;
bias = 1;
for i=1:1:36864 %192*192
    
    group_conv4_preresult = single(grouped_conv2(conv4_padding(:,:,depth),group_conv4_filter1(:,:,depth,group_conv4_filternumber)));
    group_conv4_result(1:13,result_row1:result_colm1) = group_conv4_preresult + group_conv4_result(1:13,result_row1:result_colm1);
    if depth == 192
        depth = 1;
        group_conv4_filternumber = group_conv4_filternumber + 1;
         group_conv4_result(1:13,result_row1:result_colm1) = group_conv4_result(1:13,result_row1:result_colm1) + group_conv4_bias(bias);
         result_row1 =  result_row1 + 13;
        result_colm1 = result_colm1 + 13;
        bias = bias +1;
    else
        depth = depth + 1;
    end  
    
end

group_conv4_result = reshape(group_conv4_result,[13 13 192]); %group2 conv output
%% --------------------------------------------------------------------------------------------------------------
% group4 conv process2
depth = 193;
filter_depth = 1;
group_conv4_result2 = single(zeros(13,2496)); % 13*192
group_conv4_preresult2 = zeros(13);
group_conv4_filternumber = 193;
result_row1 = 1;
result_colm1 = 13;
result_row = 1;
result_colm = 13;
bias = 193;

for i=1:1:36864 %192*192
    
    group_conv4_preresult2(1:13,result_row:result_colm) = single(grouped_conv2(conv4_padding(:,:,depth),group_conv4_filter1(:,:,filter_depth,group_conv4_filternumber)));
    group_conv4_result2(1:13,result_row1:result_colm1) = group_conv4_preresult2(1:13,result_row:result_colm) + group_conv4_result2(1:13,result_row1:result_colm1);
    if depth == 384
        depth = 193;
        filter_depth = 1;
        group_conv4_filternumber = group_conv4_filternumber + 1;
         group_conv4_result2(1:13,result_row1:result_colm1) = group_conv4_result2(1:13,result_row1:result_colm1) + group_conv4_bias(bias);
         result_row1 =  result_row1 + 13;
        result_colm1 = result_colm1 + 13;
        bias = bias +1;
    else
        depth = depth + 1;
        filter_depth = filter_depth + 1;
    end
    
end

group_conv4_result2 = reshape(group_conv4_result2,[13 13 192]);

conv4_result = cat(384,group_conv4_result,group_conv4_result2);
conv4_result = reshape(conv4_result,[13 13 384]);
%% -------------------------------------------------------------------------------------------------------------
relu4 = ReLu(conv4_result); %Layer13 output
%% -------------------------------------------------------------------------------------------------------------
conv5_padding = single(padd(relu4,1));
%group2 convolution filters
group_conv5_filter1 = single(zeros(3,3*192*256));
depth=1;
filternumber=1;
i=1;
group=1;
for j=3:3:147456 %  147456= 3*192*256
    
    group_conv5_filter1(1:3,i:j) = net.Layers(14).Weights(:,:,depth,filternumber,group);
    i=i+3;
    
    if (filternumber == 128 && depth ==192)
        depth = 1;
        filternumber = 1;
        group=2;
        
    elseif depth==192
        depth=1;
        filternumber=filternumber +1;
        
    else
        depth = depth+1;
    end
end

group_conv5_filter1 = reshape(group_conv5_filter1,[3 3 192 256]);
%% -------------------------------------------------------------------------------------------------------------
% group1 conv5 process1
depth = 1;
group_conv5_result = single(zeros(13,1664)); % 13*128
group_conv5_preresult = zeros(13);
group_conv5_bias = net.Layers(14).Bias();
group_conv5_filternumber = 1;
result_row1 = 1;
result_colm1 = 13;
bias = 1;
for i=1:1:24576 %192*128
    
    group_conv5_preresult = single(grouped_conv3(conv5_padding(:,:,depth),group_conv5_filter1(:,:,depth,group_conv5_filternumber)));
    group_conv5_result(1:13,result_row1:result_colm1) = group_conv5_preresult + group_conv5_result(1:13,result_row1:result_colm1);
    if depth == 192
        depth = 1;
        group_conv5_filternumber = group_conv5_filternumber + 1;
         group_conv5_result(1:13,result_row1:result_colm1) = group_conv5_result(1:13,result_row1:result_colm1) + group_conv5_bias(bias);
         result_row1 =  result_row1 + 13;
        result_colm1 = result_colm1 + 13;
        bias = bias +1;
    else
        depth = depth + 1;
    end  
    
end

group_conv5_result = reshape(group_conv5_result,[13 13 128]); %group3 conv output
%% --------------------------------------------------------------------------------------------------------------
% group5 conv process2
depth = 193;
filter_depth = 1;
group_conv5_result2 = single(zeros(13,1664)); % 13*128
group_conv5_preresult2 = zeros(13);
group_conv5_filternumber = 129;
result_row1 = 1;
result_colm1 = 13;
result_row = 1;
result_colm = 13;
bias = 129;

for i=1:1:24576 %192*128
    
    group_conv5_preresult2(1:13,result_row:result_colm) = single(grouped_conv3(conv5_padding(:,:,depth),group_conv5_filter1(:,:,filter_depth,group_conv5_filternumber)));
    group_conv5_result2(1:13,result_row1:result_colm1) = group_conv5_preresult2(1:13,result_row:result_colm) + group_conv5_result2(1:13,result_row1:result_colm1);
    if depth == 384
        depth = 193;
        filter_depth = 1;
        group_conv5_filternumber = group_conv5_filternumber + 1;
         group_conv5_result2(1:13,result_row1:result_colm1) = group_conv5_result2(1:13,result_row1:result_colm1) + group_conv5_bias(bias);
         result_row1 =  result_row1 + 13;
        result_colm1 = result_colm1 + 13;
        bias = bias +1;
    else
        depth = depth + 1;
        filter_depth = filter_depth + 1;
    end
end

group_conv5_result2 = reshape(group_conv5_result2,[13 13 128]);

conv5_result = cat(256,group_conv5_result,group_conv5_result2);
conv5_result = reshape(conv5_result,[13 13 256]);
%% -------------------------------------------------------------------------------------------------------------
relu5 = ReLu(conv5_result); %Layer15 output
%% -------------------------------------------------------------------------------------------------------------
%pool5
maxpool5_pre_result = zeros(6,1536); %6*256
maxpool_depth=1;
w=1;

for i = 6:6:1536 %6*256
    max_poll_filter=[0 0 0;0 0 0;0 0 0];
    maxpool5_pre_result(1:6,w:i)=single(pool1(relu5(:,:,maxpool_depth),max_poll_filter));
    w=w+6;
    maxpool_depth = maxpool_depth + 1;
    
end

max_pool5_result =single(reshape(maxpool5_pre_result,[6 6 256])); %Layer16 output
%% ---------------------------------------------------------------------------------------------------------
%% fully connected layer(Layer 17 output)
fc = zeros(1,1,4096);
fc_weights = net.Layers(17).Weights(:,:);
fc_weights = fc_weights';
fc_bias = net.Layers(17).Bias();
fc = (max_pool5_result(:)' * fc_weights);
fc = reshape (fc,[1 1 4096]);
for i= 1:1:4096
fc(:,:,i) = fc(:,:,i) + fc_bias(i);
end
fc_act = activations(net,image_1+image_mean,'fc6');
%% ---------------------------------------------------------------------------------------------------------
%% ReLu (layer 18 output)
relu18 = ReLu(fc);
%% ---------------------------------------------------------------------------------------------------------
%% Dropout (Layer 19 output)
%%dropout = 0.5 * relu18;
%%dropout_act = activations(net,image_1+image_mean,'drop6');
%% ---------------------------------------------------------------------------------------------------------
%% fully connected layer(Layer 20 output)
fc2 = zeros(1,1,4096);
fc_weights2 = net.Layers(20).Weights(:,:);
fc_weights2 = fc_weights2';
fc_bias2 = net.Layers(20).Bias();
fc2 = (relu18(:)' * fc_weights2);
fc2 = reshape (fc2,[1 1 4096]);
for i= 1:1:4096
fc2(:,:,i) = fc2(:,:,i) + fc_bias2(i);
end
fc_act2 = activations(net,image_1+image_mean,'fc7');
%% ---------------------------------------------------------------------------------------------------------
%% ReLu (layer 21 output)
relu21 = ReLu(fc2);
%%drop_act = activations(net,image_1+image_mean,'drop7');
%% ---------------------------------------------------------------------------------------------------------
%% fully connected layer(Layer 23 output)
fc3 = zeros(1,1,1000);
fc_weights3 = net.Layers(23).Weights(:,:);
fc_weights3 = fc_weights3';
fc_bias3 = net.Layers(23).Bias();
fc3 = (relu21(:)' * fc_weights3);
fc3 = reshape (fc3,[1 1 1000]);
for i= 1:1:1000
fc3(:,:,i) = fc3(:,:,i) + fc_bias3(i);
end
fc_act3 = activations(net,image_1+image_mean,'fc8');
%% ---------------------------------------------------------------------------------------------------------
%% softmax (Layer 24 output)
softmx = single(softmax(fc3));
softmx_act = activations(net,image_1+image_mean,'prob');
output_act = activations(net,image_1+image_mean,'output');
max_probabilty = max(softmx)
for i= 1:1:1000
    if(softmx(:,:,i) == max_probabilty)
        indx = i
        break;
    end
end
imshow(image);
title(char(net.Layers(end).Classes(indx)));
net.Layers(end).Classes(indx)