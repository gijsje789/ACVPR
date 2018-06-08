function full_match_percentage = rl_template_matching(img_rl_skeleton_reference, img_rl_skeleton)
% Template matching for RL sekeltonized images

% Parameters:
%  img_rl_skeleton_reference     -    reference image, RL skeletonized
%  img_rl_skeleton               -    compare image, RL skeletonized

% Returns:
%  full_match_percentage  -    output match percentage

% detect surface features of both
ptsOriginal  = detectSURFFeatures(img_rl_skeleton,'MetricThreshold',1000);
ptsCompare = detectSURFFeatures(img_rl_skeleton_reference,'MetricThreshold',1000);

% read features and valid points
[featuresOriginal,validPtsOriginal] = extractFeatures(img_rl_skeleton,ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(img_rl_skeleton_reference,ptsCompare);

% get index pairs
index_pairs = matchFeatures(featuresOriginal,featuresDistorted);

% find matched points
matchedPtsOriginal = validPtsOriginal(index_pairs(:,1));
matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));

% estimate the transformation based on the points
[tform,~,~] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'similarity');

% warp reference image to original transform
outputView = imref2d(size(img_rl_skeleton));
Ir = imwarp(img_rl_skeleton_reference,tform,'OutputView',outputView);

% add images to see effect of transformation
comb_after = Ir + img_rl_skeleton;

% calculate perfect match
full_match_percentage = 100*sum(comb_after(:) == 2)/(sum(comb_after(:) == 1) + sum(comb_after(:) == 2));


