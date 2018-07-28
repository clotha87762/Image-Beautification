%%  read images & videos
clc;
clear all;


referenceFrame = 0;

target = im2double(imread('style_2.jpg'));
inputVideo = VideoReader('sky_2.mp4');
source = im2double(inputVideo.read(1));

imwrite(source,'untouchedFrame3.jpg');

sSize = size(source);
tSize = size(target);



%%  convert rgb space to lab space

rgb2lmsMatrix = [0.3811  0.5783 0.0402;  0.1967  0.7244  0.0782; 0.0241  0.1228 0.8444 ];
lms2labMatrix = [0.5773  0.5773  0.5773; 0.4082 0.4082  -0.8164; 0.7071 -0.7071 0.0];

sourceLAB = zeros(sSize);
targetLAB = zeros(tSize);

sourceLAB = m_rgbtolab(source);
targetLAB = m_rgbtolab(target);

%sourceLAB = rgb2lab(source);
%targetLAB = rgb2lab(target);

%sourceR = source(:,:,1);
%sourceG = source(:,:,2);
%sourceB = source(:,:,3);

maskImg = imread('mask.png');
mask = zeros(size(maskImg,1),size(maskImg,2));
for a=1:size(maskImg,1)
    for b=1:size(maskImg,2)
        
        if maskImg(a,b,1) > 253 && maskImg(a,b,1) > 252 && maskImg(a,b,3) > 253
            mask(a,b) = 1;  % if mask == 1, don't take into statistical consideration
        end
        
    end
end

% convert source to lab space
%{
for i=1:sSize(1)
    for j=1:sSize(2)
        temp =reshape(  source(i,j,:) , [3 1]);
        
        for k=1:3
           if temp(k) < (1.0/255.0)
              temp(k) = 1.0/255.0; 
           end
        end
        
        temp = rgb2lmsMatrix *temp;
        %sourceLAB(i,j,:) = rgb2lmsMatrix * source(i,j,:);
        temp = log10(temp);
        sourceLAB(i,j,:) = lms2labMatrix * temp;
    end
end

for i=1:tSize(1)
    for j=1:tSize(2)
        temp = reshape(target(i,j,:),[3 1]);
         
        for k=1:3
           if temp(k) < (1.0/255.0)
              temp(k) = 1.0/255.0; 
           end
        end
        
        temp = rgb2lmsMatrix *temp;
        temp = log10(temp);
        targetLAB(i,j,:) = lms2labMatrix * temp;
        %targetLAB(i,j,:) = rgb2lmsMatrix * target(i,j,:);
        %targetLAB(i,j,:) = log10(targetLAB(i,j,:));
        %targetLAB(i,j,:) = lms2labMatriz * targetLAB(i,j,:);
    end
end
%}

%%   compute color processing

transferedLAB = zeros (sSize);
transfered = zeros(sSize);

sourceMean =  [mean2(source(:,:,1))  mean2(source(:,:,2))  mean2(source(:,:,3))];
targetMean = [mean2(target(:,:,1))  mean2(target(:,:,2))  mean2(target(:,:,3))]; 

sourceStd =  [std2(source(:,:,1))  std2(source(:,:,2))  std2(source(:,:,3))];
targetStd = [std2(target(:,:,1))  std2(target(:,:,2))  std2(target(:,:,3))]; 

sourceMeanLAB = [mean2(sourceLAB(:,:,1))  mean2(sourceLAB(:,:,2))  mean2(sourceLAB(:,:,3))];
targetMeanLAB = [mean2(targetLAB(:,:,1))  mean2(targetLAB(:,:,2))  mean2(targetLAB(:,:,3))]; 

sourceStdLAB = [std2(sourceLAB(:,:,1))  std2(sourceLAB(:,:,2))  std2(sourceLAB(:,:,3))];
targetStdLAB = [std2(targetLAB(:,:,1))  std2(targetLAB(:,:,2))  std2(targetLAB(:,:,3))];



transferedLAB(:,:,1) =  ((targetStdLAB(1)/sourceStdLAB(1)) * (sourceLAB(:,:,1) - sourceMeanLAB(1)) ) + targetMeanLAB(1);
transferedLAB(:,:,2) =  ((targetStdLAB(2)/sourceStdLAB(2)) * (sourceLAB(:,:,2) - sourceMeanLAB(2))) + targetMeanLAB(2);
transferedLAB(:,:,3) = ( (targetStdLAB(3)/sourceStdLAB(3)) * (sourceLAB(:,:,3) - sourceMeanLAB(3))  )+ targetMeanLAB(3);

%%   LAB to Rgb

lab2lmsMatrix = [0.5773 0.4082 0.7071; 0.5773 0.4082 -0.7071; 0.5773 -0.8164 0];
lms2rgbMatrix = [4.4679 -3.5873 0.1193; -1.2186 2.3809 -0.1624; 0.0497 -0.2439 1.2045];

for i=1:sSize(1)
    for j=1:sSize(2)
        temp = reshape( transferedLAB(i,j,:) , [3 1]);
        temp = lab2lmsMatrix * temp;
        temp = 10.^temp;
        transfered(i,j,:) =  lms2rgbMatrix * temp;
        %transfered(i,j,:) =  lab2lmsMatrix * transferedLAB(i,j,:);
        %transfered(i,j,:) = transfered(i,j,:).^10;
        %transfered(i,j,:) = lms2labMatrix * transfered(i,j,:);
    end
end

%transfered = lab2rgb(transferedLAB); % QQ  my code's result is not good enough as matlab's QQ
cT=makecform('lab2srgb') 
transfered =applycform( transferedLAB,cT); 



%transfered = imguidedfilter(transfered,source);
%transfered = imgaussfilt(transfered,3.5);
transfered = imguidedfilter(transfered);
imwrite(transfered,'edgepreserving.jpg');

%%

%{
output = tonemap(transfered);
output2 = imguidedfilter(transfered,source);
output3 = imguidedfilter(transfered , transfered);
output4 = imgaussfilt(transfered , 2.0);

output5 = HSVHistogramEqualize(transfered , mask);
output5 = imguidedfilter(output5,source);


figure();
imshow(transfered);


figure();
imshow(output4);

figure();
imshow(output3);

figure();
imshow(output2);

figure();
imshow(output5);
%}