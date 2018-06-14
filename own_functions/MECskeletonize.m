function img_mec_skeleton = MECskeletonize(img)

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

    % Binarise the vein image
    md = 0.01;
    img_mec_bin = v_mean_curvature > md; 

    bw1 = filledgegaps(img_mec_bin, 7);
    img_mec_skeleton  = bwareaopen(bw1,10);

end