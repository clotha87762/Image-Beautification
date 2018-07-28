function [output] = m_rgbtolab(input)
%M_RGBTOLAB Summary of this function goes here
%   Detailed explanation goes here
    
%{
    inputSize  = size(input);

    input = reshape(input,[],3);
    input = max(input,1.0/255.0);
    
    a = [0.3811 0.5783 0.0402;0.1967 0.7244 0.0782;0.0241 0.1288 0.8444];
    b = [1/sqrt(3) 0 0;0 1/sqrt(6) 0;0 0 1/sqrt(2)];
    c = [1 1 1;1 1 -2;1 -1 0];
    
    
    
    
    temp = a * input';
    temp = log10(temp);
    temp = b*c*temp;
    
    
    
    
    output = reshape(temp,inputSize);
    %}
    

    R = input(:,:,1);
    G = input(:,:,2);
    B = input(:,:,3);
    
    for i=1:size(input,1)  % Pre processing
        for j= 1:size(input,2)
              if R(i,j) < 1.0 / 255.0
                 R(i,j) = 1.0/255.0; 
              end
              if G(i,j) < 1.0 / 255.0
                 G(i,j) = 1.0/255.0; 
              end
              if B(i,j) < 1.0 / 255.0
                 B(i,j) = 1.0/255.0; 
              end    
        end
    end
    
    L = 0.3811*R + 0.5783*G + 0.0402*B;
    M = 0.1967*R + 0.7244*G + 0.0782*B;
    S = 0.0241*R + 0.1288*G + 0.8444*B; 
        
    L = log10(L); 
    M = log10(M);
    S = log10(S);
    
    l = 1.0 / sqrt(3.0)*L + 1.0 / sqrt(3.0)*M + 1.0 / sqrt(3.0)*S;
    alpha = 1.0 / sqrt(6.0)*L + 1.0 / sqrt(6.0)*M - 2.0 / sqrt(6.0)*S;
    beta = 1.0 / sqrt(2.0)*L - 1.0 / sqrt(2.0)*M + 0.0 * S;
        
    output = zeros(size(input));
    output(:,:,1) = l;
    output(:,:,2) = alpha;
    output(:,:,3) = beta;
    
   % output = rgb2lab(input);
    cT=makecform('srgb2lab') ;
    output =applycform(input,cT);
end

