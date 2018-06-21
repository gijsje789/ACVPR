function cropped = cropFingerVeinImage(fingerVein)
    blobAnalyzer = vision.BlobAnalysis('LabelMatrixOutputPort', true, ...
                                        'MinimumBlobArea', 25);
    bw_thres = graythresh(fingerVein);
    bw_im = imbinarize(fingerVein, bw_thres);
    bw_im = imdilate(bw_im, strel('rectangle', [75 75])); %big dilate to compensate for crooked fingers.
    [area, centroid, ~, ~] = blobAnalyzer(bw_im);
    [~, I] = max(area); % The blob with the largest area probably is the finger.
    cropped = fingerVein(fix(centroid(I,2))-80:fix(centroid(I,2))+80, 1:end);
end