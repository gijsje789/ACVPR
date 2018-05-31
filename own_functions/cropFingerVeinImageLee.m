function [cropped, region, edges] = cropFingerVeinImageLee(image)
    
    [region, edges] = lee_region(im2double(image), 4, 20);
    avg_edges(1) = max(edges(1,:));
    avg_edges(2) = min(edges(2,:));
    cropped = image(avg_edges(1):avg_edges(2), 1:end);

end