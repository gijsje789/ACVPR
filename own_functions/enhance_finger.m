function imout = enhance_finger(im)
% Removes regions outside finger completely, then enhances contrast using 
% Adaptive Histogram Equalization, then resizes the image. 

% Parameters:
%  im     -    target image

% Returns:
%  imout  -    outuput image

mask_height=4; % Height of the mask
mask_width=20; % Width of the mask
[fvr, edges] = lee_region(im,mask_height,mask_width);
x = 1: 1 : length(edges(2,:));

[m,n] = size(im);

for c = 1 : n
    for r = 1 : m
        if r > edges(1,c)
           im(1:r-1,c) = 0; 
           break
        end
    end
end

for c = 1 : n
    for r = 1 : m
        if r > edges(2,c)
           im(r:m,c) = 0; 
           break
        end
    end
end

ima = adapthisteq(im);
imout = imresize(ima, 0.5);

