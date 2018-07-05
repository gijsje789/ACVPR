% input two images, and compare for similarity
clc; clear; close all;

SHOW_FIGURES = true;

 load final_database
%load 'database - full.mat';
[data_count, ~] = size(data);



%im_original = im2double(imread('0023_3_2_120509-163547.png'));  %% 47

% read comparison image
im_original = data{19,1};
% read image to compare
im_compare = data{1,1};

if SHOW_FIGURES == true
    figure;
    imshow(im_original);
    %title('before Gaussian');
end

print -r300 -dpng original.png     % Print the result to file

for iteration = 1:2
    
    if iteration == 1
        img = im_original;
    else
        img = im_compare;
    end
    
    %img = enhance_finger(im2double(img));
    img = imresize(im2double(img),0.5);
    
    mask_height=4; % Height of the mask
    mask_width=20; % Width of the mask
    [~, edges] = lee_region(img,mask_height,mask_width);

    for col = 1:size(edges,2)
        img(1:edges(1,col), col) = 0;
        img(edges(2,col):end, col) = 0;
    end

    % gaussian filter
    S = im2double(img);

    sigma = 3.2;
    L = 2*ceil(sigma*3)+1;
    h = fspecial('gaussian', L, sigma);% create the PSF
    imfiltered = imfilter(S, h, 'replicate', 'conv'); % apply the filter

    S = imfiltered;

    % Mean curvature method
    v_mean_curvature = mean_curvature(S);
    
    for col = 1:size(edges,2)
        v_mean_curvature(1:edges(1,col)+2, col) = 0;
        v_mean_curvature(edges(2,col)-6:end, col) = 0;
    end
    
    %img_mec_bin = v_mean_curvature;

    % Binarise the vein image
    md = median(v_mean_curvature(v_mean_curvature>0));
    img_mec_bin = v_mean_curvature > md; 

    img_skel = bwmorph(img_mec_bin,'skel',Inf);
    
    bw1 = filledgegaps(img_skel, 7);
    img_mec_skeleton  = bwareaopen(bw1,10);
    
    % find branchpoints remaining and put in array
    bw1br = bwmorph(img_mec_skeleton, 'branchpoints');
    [i,j] = find(bw1br);
    branch_array_mec = [j,i];
    
    
    if iteration == 1
        im_original_skel = img_mec_skeleton;
        im_original = img_mec_bin;
    else
        im_compare_skel =  img_mec_skeleton;
        im_compare = img_mec_bin;
    end
    
end

% detect surface features of both
ptsOriginal  = detectSURFFeatures(im_original);
ptsCompare = detectSURFFeatures(im_compare);

% read features and valid points
[featuresOriginal,validPtsOriginal] = extractFeatures(im_original,ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(im_compare,ptsCompare);

% get index pairs
index_pairs = matchFeatures(featuresOriginal,featuresDistorted);

% find matched points
matchedPtsOriginal = validPtsOriginal(index_pairs(:,1));
matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));

% show all matched points
figure;
subplot(2,2,1);
showMatchedFeatures(im_original,im_compare,matchedPtsOriginal,matchedPtsDistorted);
title('Matched points including outliers');

% estimate the transformation based on the points
[tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'similarity');

% show useful matched points
subplot(2,2,2);
showMatchedFeatures(im_original,im_compare,inlierPtsOriginal,inlierPtsDistorted);
title('Matching points (inliers only)');

% warp compare image to original transform
outputView = imref2d(size(im_original_skel));
Ir = imwarp(im_compare_skel,tform,'OutputView',outputView);

% add images to see effect of transformation
comb_after = Ir + im_original_skel;
comb_before = im_compare_skel + im_original_skel;

% show in RG or B
comb_before(:,:,2) = im_compare_skel;
comb_before(:,:,3) = im_original_skel;

% calculate match
full_match_percentage = 100*sum(comb_after(:) == 2)/(sum(comb_after(:) == 1) + sum(comb_after(:) == 2));
c = imfuse(im_compare_skel, im_original_skel, 'colorchannels', 'green-magenta');

% show result before
subplot(2,2,3);
imshow(c);
title('merge before transform');

% show result after
subplot(2,2,4);
imshow(comb_after, [0 2]);
title(strcat('merge after transform (',num2str(round(full_match_percentage)),'% match)'));

