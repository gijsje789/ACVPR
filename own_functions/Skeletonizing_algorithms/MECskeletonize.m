function [img_mec_bin, branch_array_mec, img_mec_skeleton, v_mean_curvature] = MECskeletonize(img)

    
    mask_height=4; % Height of the mask
    mask_width=20; % Width of the mask
    [~, edges] = lee_region(img,mask_height,mask_width);

    for col = 1:size(edges,2)
        img(1:edges(1,col), col) = 0;
        img(edges(2,col):end, col) = 0;
    end

    % gaussian filter
    S = im2double(img);

    sigma = 3.2;
    L = 2*ceil(sigma*3)+1;
    h = fspecial('gaussian', L, sigma);% create the PSF
    imfiltered = imfilter(S, h, 'replicate', 'conv'); % apply the filter

    S = imfiltered;

    % Mean curvature method
    v_mean_curvature = mean_curvature(S);
    
    for col = 1:size(edges,2)
        v_mean_curvature(1:edges(1,col)+2, col) = 0;
        v_mean_curvature(edges(2,col)-6:end, col) = 0;
    end

    
    img_mec_bin = v_mean_curvature;

    % Binarise the vein image
    md = median(v_mean_curvature(v_mean_curvature>0));
    img_mec_bin = v_mean_curvature > md; 

    bw1 = filledgegaps(img_mec_bin, 7);
    img_mec_skeleton  = bwareaopen(bw1,10);
    
    % find branchpoints remaining and put in array
    bw1br = bwmorph(img_mec_skeleton, 'branchpoints');
    [i,j] = find(bw1br);
    branch_array_mec = [j,i];
    
end