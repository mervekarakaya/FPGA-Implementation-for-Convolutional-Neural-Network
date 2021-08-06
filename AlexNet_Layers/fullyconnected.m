function y = fullyconnected(x)

net = alexnet();
x = x(:)';
fc_weights = net.Layers(17).Weights(:,:);
fc_weights = fc_weights';
fc_bias = net.Layers(17).Bias();
y = (x * fc_weights)+ fc_bias;

end
  
    





