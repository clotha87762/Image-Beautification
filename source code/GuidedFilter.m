function [ q ] = GuidedFilter( I,p,r,epsilon )
%GUIDEDFILTER Summary of this function goes here
%   Detailed explanation goes here
    h = size(I,1);
    w = size(I,2);
    PatchSize = BoxFilter(ones(h,w),r);
    PMean = BoxFilter(p,r)./PatchSize;
    IMean = BoxFilter(I,r)./PatchSize;
    IIMean = BoxFilter(I.*I,r)./PatchSize;
    IPMean = BoxFilter(I.*p,r)./PatchSize;
    IVar = IIMean - IMean.*IMean;
    IPCov = IPMean - IMean.*PMean;
    a = IPCov./(IVar+ epsilon);
    b = PMean - a.*IMean;
    aMean = BoxFilter(a,r)./PatchSize;
    bMean = BoxFilter(b,r)./PatchSize;
    q = aMean.*I + bMean;
end

