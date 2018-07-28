clear all;

I = imread('lena.bmp');
I = im2double(I);

p = I;

r = 8;
epsilon = 0.2^2;
q = zeros(size(p));
q(:,:,1) = GuidedFilterColor(I,p(:,:,1),r,epsilon);
q(:,:,2) = GuidedFilterColor(I,p(:,:,2),r,epsilon);
q(:,:,3) = GuidedFilterColor(I,p(:,:,3),r,epsilon);


r = 8;
epsilon = 0.2^2;
q2 = zeros(size(p));
I = rgb2gray(I);
q2(:,:,1) = GuidedFilter(I,p(:,:,1),r,epsilon);
q2(:,:,2) = GuidedFilter(I,p(:,:,2),r,epsilon);
q2(:,:,3) = GuidedFilter(I,p(:,:,3),r,epsilon);

str =sprintf('r = %d  epsilon = %f',r,epsilon);
figure('Name',str);
imshow([p,q,q2],[0 ,1]);