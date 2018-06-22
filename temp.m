   
    img = im2double(imread('0012_1_2_120509-151806.png'));  %% 47

    img = imresize(im2double(img), 0.5);
    
    figure;
    imshow(img);
    
            
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

    [img_rl_bin, branch_array_rl, img_rl_skeleton, img_rl_grayscale] = repeatedLineTracking(img_gauss, fvr);
    
    for col = 1:size(edges,2)
        img_rl_bin(1:edges(1,col)+2, col) = 0;
        img_rl_bin(edges(2,col)-2:end, col) = 0;
    end
    figure;
    imshow(img_rl_bin);
