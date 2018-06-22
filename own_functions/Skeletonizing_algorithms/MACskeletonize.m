function [img_mac_bin, branch_array_mac, v_max_curvature, img_mac_skeleton] = MACskeletonize(img)
    img_enhanced_mac = img;

    % find Lee regions (finger region)
    fvr = lee_region(img,4,40);

    % extract veins using maximum curvature method
    v_max_curvature = miura_max_curvature(img,fvr,3);

    % binarize the vein image
    md = median(v_max_curvature(v_max_curvature>0));
    v_max_curvature_bin = v_max_curvature > md;
    
    mask_height=4; % Height of the mask
    mask_width=20; % Width of the mask
    [~, edges] = lee_region(img,mask_height,mask_width);
    for col = 1:size(edges,2)
        v_max_curvature_bin(1:edges(1,col)+4, col) = 0;
        v_max_curvature_bin(edges(2,col)-4:end, col) = 0;
    end

    img_mac_bin = v_max_curvature_bin;

    % skeletonize and fill gaps
    bw1 = filledgegaps(v_max_curvature_bin, 7);
    img_mac_skeleton  = bwareaopen(bw1,5);

    % find branchpoints remaining and put in array
    bw1br = bwmorph(img_mac_skeleton, 'branchpoints');
    [i,j] = find(bw1br);
    branch_array_mac = [j,i];
    
end