% input two images, and compare for similarity
clc; clear; close all;

DEBUG = false;

% load database
load database.mat;
[data_count, ~] = size(data);


% % read all data for first database entry
% img = data{compare_with,1};                         % cropped finger image
% person = data{compare_with,2};                      % person number
% finger = data{compare_with,3};                      % finger number
% number = data{compare_with,4};                      % photo number
% featuresOriginal = data{compare_with,5};            % features
% validPtsOriginal = data{compare_with,6};            % valid points
% lbp_info = data{compare_with,7};                    % local binary pattern
% branch_array = data{compare_with,8};                % branchpoint array
% img_rl_skeleton = data{compare_with,9};             % RL skeletonized

% read comparison image
im_original = data{1,1};
% read image to compare
im_compare = data{2,1};

if DEBUG == true
    % show individual images
    figure;
    subplot(1,2,1);
    imshow(im_compare);
    
    subplot(1,2,2);
    imshow(im_original);
end
for iteration = 1:2
    
    if iteration == 1
        img = im_original;
    else
        img = im_compare;
    end
    
    % Gabor variables
    GaborSigma = 5; dF = 2.5; F = 0.1014;
    %(sqrt( log(2/pi))*(2^dF + 1)/(2^dF - 1)) / GaborSigma;
    % should be optimal F according to Zhang and Yang.
    
    % crop image
    img = cropFingerVeinImage(img);
    S = im2double(img);
    
    % variables for Gaussian filter
    sigma = 5;
    L = 2*ceil(sigma*3)+1;
    h = fspecial('gaussian', L, sigma);% create the PSF
    imfiltered = imfilter(S, h, 'replicate', 'conv'); % apply the filter
    S = mat2gray(imfiltered, [0 256]);
    
    % repeated lines method
    fvr = ones(size(img));
    veins = repeated_line(S, fvr, 3000, 1, 17);
    
    % Binarise the vein image
    md = median(veins(veins>0));
    v_repeated_line_bin = veins > md;
    
    if DEBUG == true
        figure;
        subplot(3,3,1);
        imshow(v_repeated_line_bin);
        title('RL');
    end
    se = strel('disk',1,0);
    v_repeated_line_bin = imerode(v_repeated_line_bin,se);
    
    img = v_repeated_line_bin;
    
    if DEBUG == true
        subplot(3,3,2);
        imshow(img);
        title('eroded');
    end
    
    % clean and fill (correct isolated black and white pixels)
    img_rl_clean = bwmorph(img,'clean');
    img_rl_fill = bwmorph(img_rl_clean,'fill');
    
    if DEBUG == true
        subplot(3,3,3);
        imshow(img_rl_fill);
        title('cleaned filled');
    end
    
    % skeletonize first time
    img_rl_skel = bwmorph(img_rl_fill,'skel',inf);
    
    if DEBUG == true
        subplot(3,3,4);
        imshow(img_rl_skel);
        title('skeletonized');
    end
    
    % open filter image
    img_rl_open = bwareaopen(img_rl_skel, 5);
    
    if DEBUG == true
        subplot(3,3,5);
        imshow(img_rl_open);
        title('opened');
    end
    
    % find branchpoints & endpoints
    B = bwmorph(img_rl_open, 'branchpoints');
    E = bwmorph(img_rl_open, 'endpoints');
    
    [y,x] = find(E);
    B_loc = find(B);
    
    Dmask = false(size(img_rl_open));
    
    % find dead ends
    for i = 1:numel(x)
        D = bwdistgeodesic(img_rl_open,x(i),y(i));
        distanceToBranchPt = min(D(B_loc));
        if distanceToBranchPt < 10
            Dmask(D < distanceToBranchPt) = true;
        end
    end
    
    % subtract dead ends
    skelD = img_rl_open - Dmask;
    
    if DEBUG == true
        subplot(3,3,6);
        imshow(skelD);
        title('dead ends gone');
    end
    
    skelD = filledgegaps(skelD, 9);
    
    % clean and fill (correct isolated black and white pixels)
    img_rl_clean = bwmorph(skelD,'clean');
    img_rl_result = bwmorph(img_rl_clean,'fill');
    
    if DEBUG == true
        subplot(3,3,7);
        imshow(img_rl_result);
        title('cleaned');
    end
    
    % skeletonize again to optimize branchpoint detection
    img_rl_result = bwmorph(img_rl_result,'skel',inf);
    
    if DEBUG == true
        subplot(3,3,8);
        imshow(img_rl_result);
        title('skeletonized');
    end
    
    % find branchpoints remaining and put in array
    bw1br = bwmorph(img_rl_result, 'branchpoints');
    [i,j] = find(bw1br);
    branch_array = [j,i];
    
    if DEBUG == true
        subplot(3,3,9);
        imshow(img_rl_result); hold all;
        plot(branch_array(:,1),branch_array(:,2),'o','color','cyan','linewidth',2);
        title('skeletonized + branchpoints');
    end
    
    if iteration == 1
        im_original = img_rl_result;
    else
        im_compare = img_rl_result;
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

% estimate the transformation based on the points
[tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'similarity');

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

if DEBUG == true
    % show result before
    figure;
    subplot(1,2,1);
    imshow(comb_before);
    title('merge before transform');
    
    % show result after
    subplot(1,2,2);
    imshow(comb_after, [0 2]);
    title(strcat('merge after transform (',num2str(round(full_match_percentage)),'% match)'));
end

