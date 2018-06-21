function full_match_percentage = template_matching(img_reference, img)
% Template matching for RL/MAC/MEC binary/sekeltonized images

% Parameters:
%  img_skeleton_reference     -    reference image, RL/MAC/MEC binary/skeletonized
%  img_skeleton               -    compare image, RL/MAC/MEC binary/skeletonized

% Returns:
%  full_match_percentage  -    output match percentage

% detect surface features of both
ptsOriginal  = detectSURFFeatures(img,'MetricThreshold',1000);
ptsCompare = detectSURFFeatures(img_reference,'MetricThreshold',1000);

% read features and valid points
[featuresOriginal,validPtsOriginal] = extractFeatures(img,ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(img_reference,ptsCompare);

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
    outputView = imref2d(size(img_reference));
    Ir = imwarp(img_reference,tform,'OutputView',outputView);

    % add images to see effect of transformation
    comb_after = Ir + img;

    % calculate perfect match
    full_match_percentage = 100*sum(comb_after(:) == 2)/(sum(comb_after(:) == 1) + sum(comb_after(:) == 2));
    
else
    full_match_percentage = 0;
end



