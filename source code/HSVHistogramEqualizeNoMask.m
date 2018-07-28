function output = HSVHistogramEqualizeNoMask(input  )
%HSVHISTOGRAMEQUALIZE Summary of this function goes here
%   Detailed explanation goes here
im = input;
maxI= 255;

%convert the image rgb to hsv colour space
cim=rgb2hsv(im);

%extract v (value) component from hsv space
imv =cim(:,:,3);


imv= round(imv.*maxI);

%find bins (number of intensity level) for the input image
X0 = min(imv(:));
XL  =max(imv(:));
bins=X0:XL;

%X0=0; XL=maxI;
%bins=X0:XL;

%find histogram count for the input image with respective bins
hc=histc(imv(:),bins);
nhc = hc / sum(hc) ;
chc = cumsum(nhc);

%transfer function of  image enhancement
T = X0 + (XL-X0).*chc;
%apply transfer function on input image to get enhanced image
eimv=T(imv+1-X0);

%append enhanced v component with hsv colour

cim(:,:,3) = eimv./maxI;

%convert hsv to rgb colour space
output =hsv2rgb(cim);


end


