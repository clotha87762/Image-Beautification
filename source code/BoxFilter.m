function [ Boxed ] = BoxFilter( Image,r )
%BOXFILTER Summary of this function goes here
%   Detailed explanation goes here
    
    %Using Integral Image!!
    Boxed = zeros(size(Image));
    h = size(Image,1);
    w = size(Image,2);
    cumImg = zeros(size(Image));
    cumImg(1,:)=Image(1,:);
    for i=2:h,
       cumImg (i,:) = cumImg(i-1,:) +  Image(i,:); 
    end

    Boxed(1:r+1,:) = cumImg(1+r:1+2*r,:);
    Boxed(r+2:h-r,:) = cumImg(2+2*r:h,:) - cumImg(1:h-2*r-1,:);
    Boxed(h-r+1:h,:) = repmat(cumImg(h,:),[r,1]) - cumImg(h-2*r:h-r-1,:);
    
    
    cumImg = zeros(size(Image));
    cumImg(:,1)=Boxed(:,1);
    for i=2:w,
       cumImg (:,i) = cumImg(:,i-1) +  Boxed(:,i); 
    end
   
    Boxed(:,1:r+1) = cumImg(:,1+r:1+2*r);
    Boxed(:,r+2:w-r) = cumImg(:,2+2*r:w) - cumImg(:,1:w-2*r-1);
    Boxed(:,w-r+1:w) = repmat(cumImg(:,w),[1,r]) - cumImg(:,w-2*r:w-r-1);
    
end

