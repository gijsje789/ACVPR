function transformedImage = transformIm(im_to_compare, im_reference)

% detect surface features of both
            ptsOriginal  = detectSURFFeatures(im_to_compare,'MetricThreshold',1000);
            ptsCompare = detectSURFFeatures(im_reference,'MetricThreshold',1000);
            
            % read features and valid points
            [featuresOriginal,validPtsOriginal] = extractFeatures(im_to_compare,ptsOriginal);
            [featuresDistorted,validPtsDistorted] = extractFeatures(im_reference,ptsCompare);
            
            % get index pairs
            index_pairs = matchFeatures(featuresOriginal,featuresDistorted);
            
            % find matched points
            matchedPtsOriginal = validPtsOriginal(index_pairs(:,1));
            matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));
            
%             % show all matched points
            subplot(2,3,3);
            showMatchedFeatures(im_to_compare,im_reference,matchedPtsOriginal,matchedPtsDistorted);
            title('Matched points including outliers');
            
            % estimate the transformation based on the points
            [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'similarity');
            
%             % show useful matched points
            subplot(2,3,4);
            showMatchedFeatures(im_to_compare,im_reference,inlierPtsOriginal,inlierPtsDistorted);
            title('Matching points (inliers only)');
            
            % warp compare image to original transform
            outputView = imref2d(size(im_to_compare));
            Ir = imwarp(im_reference,tform,'OutputView',outputView);
            
            transformedImage = Ir;