function match_error = lbp_matching(img_reference, img, img_tform_reference, img_tform)
%

% Parameters:
%  img_reference     -    reference image grayscale
%  img               -    compare image grayscale
%  img_reference_tf     -    reference image bin
%  img_tf               -    compare image bin

% Returns:
%  match_error  -    gives error 0 - Inf, low error = yay

lbpBricks1 = extractLBPFeatures(img_reference,'Upright',false,'Normalization','none','NumNeighbors',8);

% detect surface features of both
ptsOriginal  = detectSURFFeatures(img_tform_reference);
ptsCompare = detectSURFFeatures(img_tform);

% read features and valid points
[featuresOriginal,validPtsOriginal] = extractFeatures(img_tform_reference,ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(img_tform,ptsCompare);

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
    
    % warp compare image to original transform
    outputView = imref2d(size(img_reference));
    Ir = imwarp(img,tform,'OutputView',outputView);
    
    lbpBricks2 = extractLBPFeatures(Ir,'Upright',false,'Normalization','none','NumNeighbors',8);
    
    brickVsBrick = (lbpBricks1 - lbpBricks2).^2;
    
    match_error = sum(brickVsBrick);
else
    match_error = -1;
end




