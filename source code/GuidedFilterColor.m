function [ q ] = GuidedFilterColor( I,p,r,epsilon )
%GUIDEDFILTERCOLOR Summary of this function goes here
%   Detailed explanation goes here
    h = size(p,1);
    w = size(p,2);
    PatchSize = BoxFilter(ones(h,w),r);
    PMean = BoxFilter(p,r)./PatchSize;
    IrMean = BoxFilter(I(:,:,1),r)./PatchSize;
    IgMean = BoxFilter(I(:,:,2),r)./PatchSize;
    IbMean = BoxFilter(I(:,:,3),r)./PatchSize;
    covIrP = (BoxFilter(I(:,:,1).*p,r)./PatchSize) - IrMean.*PMean;
    covIgP = (BoxFilter(I(:,:,2).*p,r)./PatchSize) - IgMean.*PMean;
    covIbP = (BoxFilter(I(:,:,3).*p,r)./PatchSize) - IbMean.*PMean;
    covRR = BoxFilter(I(:,:,1).*I(:,:,1),r)./PatchSize - IrMean.*IrMean;
    covRG = BoxFilter(I(:,:,1).*I(:,:,2),r)./PatchSize - IrMean.*IgMean;
    covRB = BoxFilter(I(:,:,1).*I(:,:,3),r)./PatchSize - IrMean.*IbMean;
    covGG = BoxFilter(I(:,:,2).*I(:,:,2),r)./PatchSize - IgMean.*IgMean;
    covGB = BoxFilter(I(:,:,2).*I(:,:,3),r)./PatchSize - IgMean.*IbMean;
    covBB = BoxFilter(I(:,:,3).*I(:,:,3),r)./PatchSize - IbMean.*IbMean;
    
    a = zeros(h,w,3);
    for i=1:h,
        for j=1:w,
            Sigma = [covRR(i,j),covRG(i,j),covRB(i,j);covRG(i,j),covGG(i,j),covGB(i,j);covRB(i,j),covGB(i,j),covBB(i,j)];  
            covIP = [covIrP(i,j),covIgP(i,j),covIbP(i,j)];
            a(i,j,:) = covIP * inv(Sigma + epsilon*eye(3)) ;  
        end
    end
    
    b = PMean - a(:,:,1).*IrMean - a(:,:,2).*IgMean - a(:,:,3).*IbMean;
    q = (BoxFilter(a(:,:,1),r).*I(:,:,1)...
         +BoxFilter(a(:,:,2),r).*I(:,:,2)...
         +BoxFilter(a(:,:,3),r).*I(:,:,3)...
         +BoxFilter(b,r))./PatchSize;
end

