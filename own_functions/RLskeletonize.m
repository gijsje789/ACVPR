function [img_rl_bin, branch_array_rl] = RLskeletonize(img)

    img_enhanced_rl = img;
            
    % variables for Gaussian filter
    sigma = 4; L = 2*ceil(sigma*3)+1;
    h = fspecial('gaussian', L, sigma);
    img_gauss = imfilter(img, h, 'replicate', 'conv');

    mask_height = 4; mask_width = 20;
    [fvr, edges] = lee_region(img_gauss,mask_height,mask_width);

    [m,n] = size(img);

    for col = 1:size(edges,2)
        img_gauss(1:edges(1,col), col) = 0;
        img_gauss(edges(2,col):end, col) = 0;
    end

    [img_rl_bin, branch_array_rl] = repeatedLineTracking(img_gauss, fvr);

end