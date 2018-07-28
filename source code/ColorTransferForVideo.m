%%  read images & videos
clc;
clear all;


referenceFrame = 0;



useSourceMask = 1;
useTargetMask = 0;
useHSVEqualize = 0;
useGaussianBlur = 0;
useBilateral = 0;
useGuidedFilter = 1;

sourceMaskName = 'mask.png';
targetMaskName = 'maskTarget.png';
sourceName = 'sky_3.mp4';
targetName = 'style_3.jpg';


%%  convert rgb space to lab space


inputVideo = VideoReader(sourceName);
target = im2double(imread(targetName));

rgb2lmsMatrix = [0.3811  0.5783 0.0402;  0.1967  0.7244  0.0782; 0.0241  0.1228 0.8444 ];
lms2labMatrix = [0.5773  0.5773  0.5773; 0.4082 0.4082  -0.8164; 0.7071 -0.7071 0.0];


video = im2double(inputVideo.read([1 Inf]));
outputVideo = zeros(size(video));
outputNoFilterVideo = zeros(size(video));

if useSourceMask==1
    maskImg = imread(sourceMaskName);
    mask = zeros(size(maskImg,1),size(maskImg,2));

    for a=1:size(maskImg,1)
        for b=1:size(maskImg,2)

            if maskImg(a,b,1) > 253 && maskImg(a,b,1) > 252 && maskImg(a,b,3) > 253
                mask(a,b) = 1;  % if mask == 1, don't take into statistical consideration
            end

        end
    end
end


if useTargetMask == 1
    maskImg = imread(targetMaskName);
    maskTarget = zeros(size(maskImg,1),size(maskImg,2));

    for a=1:size(maskImg,1)
        for b=1:size(maskImg,2)

            if maskImg(a,b,1) > 253 && maskImg(a,b,1) > 252 && maskImg(a,b,3) > 253
                maskTarget(a,b) = 1;  % if mask == 1, don't take into statistical consideration
            end

        end
    end
    
end

for k = 1:size(video,4)
    
    disp(k);
    
    source = video(:,:,:,k);
    
    sSize = size(source);
    tSize = size(target);
    sourceLAB = zeros(sSize);
    sourceLAB = m_rgbtolab(source);
    
    if k == 1
        targetLAB = zeros(tSize);
        targetLAB = m_rgbtolab(target);
    end
    %sourceLAB = rgb2lab(source);
    %targetLAB = rgb2lab(target);

    %sourceR = source(:,:,1);
    %sourceG = source(:,:,2);
    %sourceB = source(:,:,3);



    transferedLAB = zeros (sSize);
    transfered = zeros(sSize);

    sourceMean =  [mean2(source(:,:,1))  mean2(source(:,:,2))  mean2(source(:,:,3))];
   

    sourceStd =  [std2(source(:,:,1))  std2(source(:,:,2))  std2(source(:,:,3))];
    
    if useSourceMask == 1
        s1 = sourceLAB(:,:,1);
        s2 = sourceLAB(:,:,2);
        s3 = sourceLAB(:,:,3);
        sourceMeanLAB = [mean(s1(mask==0))  mean(s2(mask==0))  mean(s3(mask==0))];
        sourceStdLAB = [std(s1(mask==0))  std(s2(mask==0))  std(s3(mask==0))];
    else
        sourceMeanLAB = [mean2(sourceLAB(:,:,1))  mean2(sourceLAB(:,:,2))  mean2(sourceLAB(:,:,3))];
        sourceStdLAB = [std2(sourceLAB(:,:,1))  std2(sourceLAB(:,:,2))  std2(sourceLAB(:,:,3))];
    end
    
    if k==1    
        
        if useTargetMask ==1
            t1 = targetLAB(:,:,1);
            t2 = targetLAB(:,:,2);
            t3 = targetLAB(:,:,3);
            targetMeanLAB = [mean(t1(maskTarget==0))  mean(t2( maskTarget==0))  mean(t3( maskTarget==0))];
            targetStdLAB = [std(t1( maskTarget==0))  std(t2( maskTarget==0))  std(t3( maskTarget==0))];
        else
            targetMean = [mean2(target(:,:,1))  mean2(target(:,:,2))  mean2(target(:,:,3))]; 
            targetStd = [std2(target(:,:,1))  std2(target(:,:,2))  std2(target(:,:,3))]; 
            targetMeanLAB = [mean2(targetLAB(:,:,1))  mean2(targetLAB(:,:,2))  mean2(targetLAB(:,:,3))];
            targetStdLAB = [std2(targetLAB(:,:,1))  std2(targetLAB(:,:,2))  std2(targetLAB(:,:,3))];
        end
        
    end


    transferedLAB(:,:,1) =  ((targetStdLAB(1)/sourceStdLAB(1)) * (sourceLAB(:,:,1) - sourceMeanLAB(1)) ) + targetMeanLAB(1);
    transferedLAB(:,:,2) =  ((targetStdLAB(2)/sourceStdLAB(2)) * (sourceLAB(:,:,2) - sourceMeanLAB(2))) + targetMeanLAB(2);
    transferedLAB(:,:,3) = ( (targetStdLAB(3)/sourceStdLAB(3)) * (sourceLAB(:,:,3) - sourceMeanLAB(3))  )+ targetMeanLAB(3);

    if useSourceMask == 1
        temp = transferedLAB(:,:,1);
        temp( find(mask==1) ) = s1( find(mask==1));
        transferedLAB(:,:,1) = temp;
        temp = transferedLAB(:,:,2);
        temp( find(mask==1) ) = s2( find(mask==1));
        transferedLAB(:,:,2) = temp;
         temp = transferedLAB(:,:,3);
        temp( find(mask==1) ) = s3( find(mask==1));
        transferedLAB(:,:,3) = temp;
    end
    
    lab2lmsMatrix = [0.5773 0.4082 0.7071; 0.5773 0.4082 -0.7071; 0.5773 -0.8164 0];
    lms2rgbMatrix = [4.4679 -3.5873 0.1193; -1.2186 2.3809 -0.1624; 0.0497 -0.2439 1.2045];
    
%{
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
    %}
    
    cT=makecform('lab2srgb') 
    transfered =applycform( transferedLAB,cT); 
    
    r = 8;
    epsilon = 0.2^2;
    
    if useHSVEqualize == 1  && useSourceMask == 1
       transfered = HSVHistogramEqualize(transfered,mask); 
    elseif useHSVEqualize == 1 && useSourceMask == 0
       transfered = HSVHistogramEqualizeNoMask(transfered);   
    end
    
    if useGuidedFilter == 1
        outputVideo(:,:,:,k) = imguidedfilter(transfered,source);
    elseif useBilateral == 1
         outputVideo(:,:,:,k) = imguidedfilter(transfered);
    elseif useGaussianBlur == 1
          outputVideo(:,:,:,k) = imgaussfilt(transfered,3.5);
    else
          outputVideo(:,:,:,k) = transfered;
    end
    %outputVideo(:,:,1,k) = GuidedFilterColor( transfered , source(:,:,1) ,r,epsilon);
    %outputVideo(:,:,2,k) = GuidedFilterColor( transfered , source(:,:,2) ,r,epsilon);
    %outputVideo(:,:,3,k) = GuidedFilterColor( transfered , source(:,:,3) ,r,epsilon);
    
   % outputNoFilterVideo(:,:,:,k) = transfered;
    
end

%%
outputVideo( outputVideo > 1.0) = 1.0;
outputVideo( outputVideo < 0) = 0;

%outputNoFilterVideo( outputNoFilterVideo > 1.0) = 1.0;
%outputNoFilterVideo( outputNoFilterVideo < 0) = 0;


videoWriter = VideoWriter('output33');
open(videoWriter)
writeVideo(videoWriter,outputVideo);
close(videoWriter);


%{
videoWriter = VideoWriter('output23_NOFILTER');
open(videoWriter)
writeVideo(videoWriter,outputNoFilterVideo);
close(videoWriter);
%}



