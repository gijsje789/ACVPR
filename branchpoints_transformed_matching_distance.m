% input two images, and compare for similarity
clc; clear; close all;

% to compare
compare_folder = 1; % person = folder number (1-9)
compare_photo = 1; % reference picture number in compare_folder (1-24)

branch_array_normal = [];

for compare_with_photo = 2:2
    
    text_in = ['data_mc\000'  num2str(compare_folder) '\' num2str(compare_photo) '.png']; % input to compare
    text_in_ref = ['data_mc\000'  num2str(compare_folder) '\' num2str(compare_with_photo) '.png']; % input compare with
    
    % read comparison image
    im_original  = imread(text_in_ref);
    % read image to compare
    im_compare = imread(text_in);
    
    % show individual images
    figure;
    subplot(2,3,1);
    imshow(im_compare);
    title(strcat('person',num2str(compare_folder),', photo',num2str(compare_photo)));
    
    subplot(2,3,2);
    imshow(im_original);
    title(strcat('person',num2str(compare_folder),', photo',num2str(compare_with_photo)));
    
    for iteration = 1:2
        
        % alternate between original and comparing image
        if iteration == 1
            img_rl = im_original;
        else
            img_rl = im_compare;
        end
        
        % clean and fill (correct isolated black and white pixels)
        img_rl_clean = bwmorph(img_rl,'clean');
        img_rl_fill = bwmorph(img_rl_clean,'fill');
        
        % open filter image
        img_rl_open = bwareaopen(img_rl_fill, 2000);
        
        % make average eliminating loose pixels
        img_rl_majority = bwmorph(img_rl_open,'majority');
        
        % skeletonize first time
        img_rl_skel = bwmorph(img_rl_majority,'skel',inf);
        
        % find branchpoints & endpoints
        B = bwmorph(img_rl_skel, 'branchpoints');
        E = bwmorph(img_rl_skel, 'endpoints');
        
        % branch, end points
        [y,x] = find(E);
        B_loc = find(B);
        Dmask = false(size(img_rl_skel));
        
        % find dead ends
        for i = 1:numel(x)
            D = bwdistgeodesic(img_rl_skel,x(i),y(i));
            distanceToBranchPt = min(D(B_loc));
            Dmask(D < distanceToBranchPt) = true;
        end
        
        % subtract dead ends
        skelD = img_rl_skel - Dmask;
        
        % clean and fill (correct isolated black and white pixels)
        img_rl_clean = bwmorph(skelD,'clean');
        img_rl_result = bwmorph(img_rl_clean,'fill');
        
        % skeletonize again to optimize branchpoint detection
        img_rl_result = bwmorph(img_rl_result,'skel',inf);
        
        % find branchpoints remaining and put in array
        bw1br = bwmorph(img_rl_result, 'branchpoints');
        [i,j] = find(bw1br);
        branch_array = [j,i];
        
        % alternate between original and comparing image
        if iteration == 1
            im_original = img_rl_result;
            branch_array_normal = branch_array;
        else
            im_compare = img_rl_result;
            %branch_array_it2 = branch_array;
        end
        
    end
    
    % detect surface features of both
    ptsOriginal  = detectSURFFeatures(im_original);
    ptsCompare = detectSURFFeatures(im_compare);
    
    % read features and valid points
    [featuresOriginal,validPtsOriginal] = extractFeatures(im_original,ptsOriginal);
    [featuresDistorted,validPtsDistorted] = extractFeatures(im_compare,ptsCompare);
    
    % get index pairs
    index_pairs = matchFeatures(featuresOriginal,featuresDistorted);
    
    % find matched points
    matchedPtsOriginal = validPtsOriginal(index_pairs(:,1));
    matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));
    
    % show all matched points
    subplot(2,3,3);
    showMatchedFeatures(im_original,im_compare,matchedPtsOriginal,matchedPtsDistorted);
    title('Matched points including outliers');
    
    % estimate the transformation based on the points
    [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'similarity');
    
    % show useful matched points
    subplot(2,3,4);
    showMatchedFeatures(im_original,im_compare,inlierPtsOriginal,inlierPtsDistorted);
    title('Matching points (inliers only)');
    
    % warp compare image to original transform
    outputView = imref2d(size(im_original));
    Ir = imwarp(im_compare,tform,'OutputView',outputView);
    
    
    
    
    % add images to see effect of transformation
    comb_after = Ir + im_original;
    comb_before = im_compare + im_original;
    
    % show in RG or B for clarification
    comb_before(:,:,1) = im_compare;
    comb_before(:,:,3) = im_original;
    
    % show result before
%     subplot(2,3,5);
%     imshow(comb_before);
%     title('merge before transform');
    
%% debug
    % find branchpoints remaining and put in array
    bw1br = bwmorph(Ir, 'branchpoints');
    [i,j] = find(bw1br);
    branch_array_warped = [j,i];

    
    figure(3);
    imshow(comb_after, [0 2]);
    hold all;
    plot(branch_array_normal(:,1),branch_array_normal(:,2),'o','color','cyan','linewidth',2);
    plot(branch_array_warped(:,1),branch_array_warped(:,2),'o','color','red','linewidth',2);
    %%
    
    % calculate match
    full_match_percentage = 100*sum(comb_after(:) == 2)/(sum(comb_after(:) == 1) + sum(comb_after(:) == 2));
    
    % show result after
%     subplot(2,3,6);
%     imshow(comb_after, [0 2]);
%     title(strcat('merge after transform (',num2str(round(full_match_percentage)),'% match)'));
    
%     % if more than 5% similarity, it can be considered a match
%     if full_match_percentage > 5
%         hold on;
%         plot(336,1,'o','linewidth',7,'color','green');
%     else
%         hold on;
%         plot(336,1,'o','linewidth',7,'color','red');
%     end
end

