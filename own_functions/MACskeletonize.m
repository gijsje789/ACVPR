function [img_mac_bin, branch_array_mac] = MACskeletonize(img)
    img_enhanced_mac = img;

    % find Lee regions (finger region)
    fvr = lee_region(img,4,40);

    % extract veins using maximum curvature method
    v_max_curvature = miura_max_curvature(img,fvr,3);

    % binarize the vein image
    md = median(v_max_curvature(v_max_curvature>0));
    v_max_curvature_bin = v_max_curvature > md;

    img_mac_bin = v_max_curvature_bin;

    % skeletonize and fill gaps
    bw1 = filledgegaps(v_max_curvature_bin, 7);
    img_mac_skeleton  = bwareaopen(bw1,5);

    % find branchpoints remaining and put in array
    bw1br = bwmorph(img_mac_skeleton, 'branchpoints');
    [i,j] = find(bw1br);
    branch_array_mac = [j,i];
end