% input two images, and compare for similarity
clc; clear; close all;

SHOW_FIGURES = true;

% load database
load database_maikel.mat;
[data_count, ~] = size(data);

% read comparison image
im_original = data{1,1};
% read image to compare
im_compare = data{2,1};

if SHOW_FIGURES == true
    figure;
    imshow(im_original);
    title('before Gaussian');
end

for iteration = 1:2
    
    if iteration == 1
        img = im_original;
    else
        img = im_compare;
    end
    
    img = enhance_finger(im2double(img));
    
    % variables for Gaussian filter
    sigma = 4; L = 2*ceil(sigma*3)+1;
    h = fspecial('gaussian', L, sigma);
    img = imfilter(img, h, 'replicate', 'conv');
    
    if SHOW_FIGURES == true
        figure;
        imshow(img);
        title('after Gaussian');
    end
    
    mask_height = 4; mask_width = 20; 
    [fvr, edges] = lee_region(img,mask_height,mask_width);
    %x = 1: 1 : length(edges(2,:));
    
    [m,n] = size(img);
    
    for c = 1 : n
        for r = 1 : m
            if r > edges(1,c)
                img(1:r-1,c) = 0;
                break
            end
        end
    end
    
    for c = 1 : n
        for r = 1 : m
            if r > edges(2,c)
                img(r:m,c) = 0;
                break
            end
        end
    end
    
    % repeated lines method
    %fvr = ones(size(im));
    veins = repeated_line(img, fvr, 3000, 1, 17);
    
    for c = 1 : n
        for r = 1 : m
            if r > edges(1,c)
                veins(1:r,c) = 0;
                break
            end
        end
    end
    
    for c = 1 : n
        for r = 1 : m
            if r > edges(2,c)
                veins(r-1:m,c) = 0;
                break
            end
        end
    end
    
    if SHOW_FIGURES == true
        figure;
        imshow(veins);
        title('RL veins');
    end
    
    % Binarise the vein image
    md = median(veins(veins>0));
    v_repeated_line_bin = veins > md;
    
    if SHOW_FIGURES == true
        figure;
        imshow(v_repeated_line_bin);
        title('RL veins bin');
    end
    
    img = v_repeated_line_bin;
    
    % resize image according to the paper
    size(img);
    img_conv = conv2(img,[1,1,1;1,1,1],'valid');
    img = img_conv(1:3:end,1:3:end)/6;
    
    if SHOW_FIGURES == true
        figure;
        imshow(img);
        title('resized image');
    end
    
    thresh = multithresh(img,2);
    img = imquantize(img,thresh);
    
    if SHOW_FIGURES == true
        figure;
        imshow(img,[]);
        title('3 thresholded image');
    end
    
    img = img > 1;
    
    % clean and fill (correct isolated black and white pixels)
    img_rl_clean = bwmorph(img,'clean');
    img_rl_fill = bwmorph(img_rl_clean,'fill');
    
    if SHOW_FIGURES == true
        figure;
        imshow(img_rl_fill);
        title('cleaned filled');
    end
    
    % skeletonize first time
    img_rl_skel = bwmorph(img_rl_fill,'skel',inf);
    
    if SHOW_FIGURES == true
        figure;
        imshow(img_rl_skel);
        title('skeletonized');
    end
    
    % open filter image
    img_rl_open = bwareaopen(img_rl_skel, 10);
    
    img_filledgaps = filledgegaps(img_rl_open, 7);
    
    if SHOW_FIGURES == true
        figure;
        imshow(img_filledgaps);
        title('opened + fg');
    end
    
    % find branchpoints & endpoints
    B = bwmorph(img_filledgaps, 'branchpoints');
    E = bwmorph(img_filledgaps, 'endpoints');
    
    [y,x] = find(E);
    B_loc = find(B);
    
    Dmask = false(size(img_filledgaps));
    
    % find dead ends
    for i = 1:numel(x)
        D = bwdistgeodesic(img_filledgaps,x(i),y(i));
        distanceToBranchPt = min(D(B_loc));
        if distanceToBranchPt < 10
            Dmask(D < distanceToBranchPt) = true;
        end
    end
    
    % subtract dead ends
    skelD = img_filledgaps - Dmask;
    
    if SHOW_FIGURES == true
        figure;
        imshow(skelD);
        title('dead ends gone');
    end
    
    % clean and fill (correct isolated black and white pixels)
    img_rl_clean = bwmorph(skelD,'clean');
    img_rl_result = bwmorph(img_rl_clean,'fill');
    
    if SHOW_FIGURES == true
        figure;
        imshow(img_rl_result);
        title('cleaned');
    end
    
    % skeletonize again to optimize branchpoint detection
    img_rl_result = bwmorph(img_rl_result,'skel',inf);
    
    if SHOW_FIGURES == true
        figure;
        imshow(img_rl_result);
        title('skeletonized');
    end
    
    % find branchpoints remaining and put in array
    bw1br = bwmorph(img_rl_result, 'branchpoints');
    [i,j] = find(bw1br);
    branch_array = [j,i];
    
    if SHOW_FIGURES == true
        figure;
        imshow(img_rl_result); hold all;
        plot(branch_array(:,1),branch_array(:,2),'o','color','cyan','linewidth',2);
        title('skeletonized + branchpoints');
    end
    
    if iteration == 1
        im_original_skel = img_rl_result;
        im_original = img_rl_fill;
    else
        im_compare_skel = img_rl_result;
        im_compare = img_rl_fill;
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
outputView = imref2d(size(im_original));
Ir = imwarp(im_compare,tform,'OutputView',outputView);

% add images to see effect of transformation
comb_after = Ir + im_original;
comb_before = im_compare + im_original;

% show in RG or B
comb_before(:,:,1) = im_compare;
comb_before(:,:,3) = im_original;

% calculate match
full_match_percentage = 100*sum(comb_after(:) == 2)/(sum(comb_after(:) == 1) + sum(comb_after(:) == 2));

% show result before
subplot(2,2,3);
imshow(comb_before);
title('merge before transform');

% show result after
subplot(2,2,4);
imshow(comb_after, [0 2]);
title(strcat('merge after transform (',num2str(round(full_match_percentage)),'% match)'));

