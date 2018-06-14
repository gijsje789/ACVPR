clc; clear; close all;

% load database
load 'database.mat';
[data_count, ~] = size(data);

array = [];

for i = 1:48
    for j = 1:48
        
        reference_im = data{i,12};
        compare_im = data{j,12};
        
        reference_im_bin = data{i,6};
        compare_im_bin = data{j,6};
        
        lbpBricks1 = extractLBPFeatures(reference_im,'Upright',false,'Normalization','none','NumNeighbors',8);
        
        % detect surface features of both
        ptsOriginal  = detectSURFFeatures(reference_im_bin);
        ptsCompare = detectSURFFeatures(compare_im_bin);
        
        % read features and valid points
        [featuresOriginal,validPtsOriginal] = extractFeatures(reference_im_bin,ptsOriginal);
        [featuresDistorted,validPtsDistorted] = extractFeatures(compare_im_bin,ptsCompare);
        
        % get index pairs
        index_pairs = matchFeatures(featuresOriginal,featuresDistorted);

        % find matched points
        matchedPtsOriginal = validPtsOriginal(index_pairs(:,1));
        matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));

        % estimate the transformation based on the points
        [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'similarity');

        % warp compare image to original transform
        outputView = imref2d(size(reference_im));
        Ir = imwarp(compare_im,tform,'OutputView',outputView);
    
        lbpBricks2 = extractLBPFeatures(Ir,'Upright',false,'Normalization','none','NumNeighbors',8);
        
        brickVsBrick = (lbpBricks1 - lbpBricks2).^2;
        
        array(i,j) = sum(brickVsBrick);
        fprintf('');
        
    end
end

