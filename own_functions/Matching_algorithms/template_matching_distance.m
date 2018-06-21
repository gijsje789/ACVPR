function error_distance = template_matching_distance(img_skel_reference, img_skel)
% Template matching for RL/MAC/MEC binary/sekeltonized images

% Parameters:
%  img_skeleton_reference     -    reference image, RL/MAC/MEC skeletonized
%  img_skeleton               -    compare image, RL/MAC/MEC skeletonized

% Returns:
%  error_distance  -    output error

% detect surface features of both
ptsOriginal  = detectSURFFeatures(img_skel,'MetricThreshold',1000);
ptsCompare = detectSURFFeatures(img_skel_reference,'MetricThreshold',1000);

% read features and valid points
[featuresOriginal,validPtsOriginal] = extractFeatures(img_skel,ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(img_skel_reference,ptsCompare);

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
    outputView = imref2d(size(img_skel));
    Ir = imwarp(img_skel_reference,tform,'OutputView',outputView);
    
    % distance transform
    dist_img2 = bwdist(img_skel,'chessboard');
    
    % get row and col count
    [rows, cols] = size(Ir);
    
    error_distance = 0;
    
    % for skeleton image 1, check value for distance image 2
    for row=1:rows
        for col=1:cols
            
            if Ir(row, col) == 1
                error_distance = error_distance + dist_img2(row, col);
            end
            
        end
    end
    
    
    
    %     % add images to see effect of transformation
    %     comb_after = Ir + img_skel;
    %     % calculate perfect match
    %     error_distance = 100*sum(comb_after(:) == 2)/(sum(comb_after(:) == 1) + sum(comb_after(:) == 2));
    
else
    error_distance = -1;
end



