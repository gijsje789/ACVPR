function full_match_percentage = distance_tr_test(skel_1, skel_2)

%clc; clear; close all;

%skel_1 = imread('test1.png');
%skel_2 = imread('test2.png');

% figure;
% imshow(skel_1,[]);
% title('original');

% detect surface features of both
ptsOriginal  = detectSURFFeatures(skel_1,'MetricThreshold',1000);
ptsCompare = detectSURFFeatures(skel_2,'MetricThreshold',1000); %reference

% read features and valid points
[featuresOriginal,validPtsOriginal] = extractFeatures(skel_1,ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(skel_2,ptsCompare);

% get index pairs
index_pairs = matchFeatures(featuresOriginal,featuresDistorted);

% find matched points
matchedPtsOriginal = validPtsOriginal(index_pairs(:,1));
matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));

errorFlag = 0;

try
    
    % estimate the transformation based on the points
    [tform,~,~] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'similarity');
    
catch
    warning('Problem using estimate tf.  Probably not enough inliers.');
    errorFlag = 1;
end
if errorFlag == 0
    
    
    % warp reference image to original transform
    outputView = imref2d(size(skel_1));
    Ir = imwarp(skel_2,tform,'OutputView',outputView);

    dist_img2 = bwdist(Ir,'chessboard');

    max_distance = max(dist_img2(:));

    % get row and col count
    [rows, cols] = size(skel_1);

    total_pixels_found = 0;
    points = 0;

    % for skeleton image 1, check value for distance image 2
    for row=1:rows
        for col=1:cols
            if skel_1(row, col) == 1
                points = points + dist_img2(row, col);
                total_pixels_found = total_pixels_found + 1;
            end

        end
    end

    % get mean distance
    mean_distance = points/total_pixels_found;

    full_match_percentage = 100 - (mean_distance/max_distance*100);
    
else
    full_match_percentage = 0;
end

% skel_1 = 60*skel_1;
% comb = skel_1 + dist_img2;
% 
% figure;
% imshow(comb, []);
% title('both');




