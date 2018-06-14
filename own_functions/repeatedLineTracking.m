function [img_rl_bin, branch_array_rl] = repeatedLineTracking(img_gauss, fvr)

    % repeated lines method
    %fvr = ones(size(im));
    veins = repeated_line(img_gauss, fvr, 3000, 1, 17);

    % binarize the vein image
    md = median(veins(veins>0));
    v_repeated_line_bin = veins > md;

    % clean and fill (correct isolated black and white pixels)
    img_rl_clean = bwmorph(v_repeated_line_bin,'clean');
    img_rl_fill = bwmorph(img_rl_clean,'fill');

    % for export to database
    img_rl_bin = img_rl_fill;

    % skeletonize first time
    img_rl_skel = bwmorph(img_rl_fill,'skel',inf);

    % open filter image
    img_rl_open = bwareaopen(img_rl_skel, 10);

    % fill gaps smaller than 7 pixels
    img_filledgaps = filledgegaps(img_rl_open, 7);

    % remove dead ends shorter than 10 pixels
    skelD = removeDeadEnds(img_filledgaps, 10);

    % clean and fill (correct isolated black and white pixels)
    img_rl_clean = bwmorph(skelD,'clean');
    img_rl_result = bwmorph(img_rl_clean,'fill');

    % skeletonize again to optimize branchpoint detection
    img_rl_skeleton = bwmorph(img_rl_result,'skel',inf);

    % find branchpoints remaining and put in array
    bw1br = bwmorph(img_rl_skeleton, 'branchpoints');
    [i,j] = find(bw1br);
    branch_array_rl = [j,i];

end