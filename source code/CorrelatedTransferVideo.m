%%  read images & videos
clc;
clear all;


referenceFrame = 0;





useSourceMask = 1;
useTargetMask = 0;
useHSVEqualize = 0;
useGaussianBlur = 0;  % priority: guided > bilateral > gaussian
useBilateral = 0;
useGuidedFilter = 1;

sourceMaskName = 'mask.png';
targetMaskName = 'maskTarget.png';
sourceName = 'sky_1.mp4';
targetName = 'style_1.jpg';

maskOnlyInEqualize = 0;


%%  convert rgb space to lab space

inputVideo = VideoReader(sourceName);
target = im2double(imread(targetName));



rgb2lmsMatrix = [0.3811  0.5783 0.0402;  0.1967  0.7244  0.0782; 0.0241  0.1228 0.8444 ];
lms2labMatrix = [0.5773  0.5773  0.5773; 0.4082 0.4082  -0.8164; 0.7071 -0.7071 0.0];


video = im2double(inputVideo.read([1 Inf]));
outputVideo = zeros(size(video));
guidedVideo = zeros(size(video));



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



if useTargetMask == 1
        t1 = target(:,:,1); t1 = t1(maskTarget==0);
        t2 = target(:,:,2); t2 = t2(maskTarget==0);
        t3 = target(:,:,3); t3 = t3(maskTarget==0);
        tgt = [t1 t2 t3]';
       % target = cat(3,t1,t2);
       % target = cat(3,target,t3);
else        
       tgt = reshape(target,[],3)'; 
end



for k = 1:size(video,4)

    disp(k);
    
    source = video(:,:,:,k);
    oriSource = video(:,:,:,k);
    
    
    orisrc = reshape(oriSource,[],3)';
    
  
    
    if useSourceMask == 1 && maskOnlyInEqualize == 0
        s1 = source(:,:,1); s1 = s1(mask==0);
        s2 = source(:,:,2); s2 = s2(mask==0);
        s3 = source(:,:,3); s3 = s3(mask==0);
        src = [ s1 s2 s3]';
        %source = cat(3,s1,s2);
        %source = cat(3,source,s3);
    else    
       src = reshape(source,[],3)';
    end
    
    %src = reshape(source,[],3)';
    
    sMean = mean(src,2);
    tMean = mean(tgt,2);
    sCov = cov(src');
    tCov = cov(tgt');
    
    [Us,Ls,Vs ] = svd(sCov);
    [Ut,Lt,Vt ] = svd(tCov);
    
  
    
    sTrans = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
   
    tTrans = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
    sTrans(1:3,4) =  -sMean;
    tTrans(1:3,4) = tMean;
    
    tRot = [Ut(1,:) 0;Ut(2,:) 0;Ut(3,:) 0; 0 0 0 1];
    x = inv(Us);
    sRot = [x(1,:) 0;x(2,:) 0;x(3,:) 0; 0 0 0 1];
    
    x = diag(Lt).^(0.2);
    tScale =  [x(1) 0 0 0;0 x(2) 0 0;0 0 x(3) 0 ;0 0 0 1;];
    %([diag(Lt).^(0.1);0 0 0 1]);
    x = diag(Ls).^(-0.2);
    sScale =   [x(1) 0 0 0;0 x(2) 0 0;0 0 x(3) 0 ;0 0 0 1;];
    
      srcHomo = [orisrc;ones(1,size(orisrc,2))];
    
    temp = tTrans*tRot*tScale*sScale*sRot*sTrans *srcHomo; % estimated RGBs
    temp =  temp ./ temp(4,:);
    temp = temp(1:3,:);
    
    result = reshape(temp',size(oriSource));
    
     if useSourceMask == 1  && maskOnlyInEqualize == 0
        s1 = oriSource(:,:,1); 
        s2 = oriSource(:,:,2); 
        s3 = oriSource(:,:,3); 
         
        temp = result(:,:,1);
        temp( find(mask==1) ) = s1( find(mask==1));
        result(:,:,1) = temp;
        temp = result(:,:,2);
        temp( find(mask==1) ) = s2( find(mask==1));
        result(:,:,2) = temp;
         temp = result(:,:,3);
        temp( find(mask==1) ) = s3( find(mask==1));
        result(:,:,3) = temp;
    end
    
   if useHSVEqualize == 1  && useSourceMask == 1
       result = HSVHistogramEqualize(result,mask); 
    elseif useHSVEqualize == 1 && useSourceMask == 0
       result = HSVHistogramEqualizeNoMask(result);   
    end
    
    
    if useGuidedFilter == 1
        outputVideo(:,:,:,k) = imguidedfilter(result,oriSource);
    elseif useBilateral == 1
        outputVideo(:,:,:,k) = imguidedfilter(result);
    elseif useGaussianBlur == 1
        outputVideo(:,:,:,k) = imgaussfilt( result,3.5);
    else
        outputVideo(:,:,:,k) = result;
    end
    
end

%%

outputVideo( outputVideo > 1.0) = 1.0;
outputVideo( outputVideo < 0) = 0;

videoWriter = VideoWriter('c_output3');
open(videoWriter)
writeVideo(videoWriter,outputVideo);
close(videoWriter);