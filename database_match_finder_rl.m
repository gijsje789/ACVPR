% input two images, and compare for similarity
clc; clear; close all;

DEBUG = false;

% load database
load database.mat;
[data_count, ~] = size(data);

% empty matches array
matches_array = [];

for compare = 1:data_count
    % read all data for first database entry
    img_reference = data{compare,1};                         % cropped finger image
    person_reference = data{compare,2};                      % person number
    finger_reference = data{compare,3};                      % finger number
    number_reference = data{compare,4};                      % photo number
    featuresOriginal_reference = data{compare,5};            % features
    validPtsOriginal_reference = data{compare,6};            % valid points
    lbp_info_reference = data{compare,7};                    % local binary pattern
    branch_array_reference = data{compare,8};                % branchpoint array
    img_rl_skeleton_reference = data{compare,9};             % RL skeletonized
    
    for compare_with = 1:data_count
        
        % read all data for first database entry
        img = data{compare_with,1};                         % cropped finger image
        person = data{compare_with,2};                      % person number
        finger = data{compare_with,3};                      % finger number
        number = data{compare_with,4};                      % photo number
        featuresOriginal = data{compare_with,5};            % features
        validPtsOriginal = data{compare_with,6};            % valid points
        lbp_info = data{compare_with,7};                    % local binary pattern
        branch_array = data{compare_with,8};                % branchpoint array
        img_rl_skeleton = data{compare_with,9};             % RL skeletonized
        
        if DEBUG == true
            % show individual images
            figure;
            subplot(1,2,1);
            imshow(img_reference);
            title('reference finger');
            
            % show individual images
            subplot(1,2,2);
            imshow(img);
            title(strcat('P:',num2str(person),', F:',num2str(finger),', N:',num2str(number)));
        end
        
        %% ================== method specific =============================
        
        % detect surface features of both
        ptsOriginal  = detectSURFFeatures(img_rl_skeleton);
        ptsCompare = detectSURFFeatures(img_rl_skeleton_reference);
        
        % read features and valid points
        [featuresOriginal,validPtsOriginal] = extractFeatures(img_rl_skeleton,ptsOriginal);
        [featuresDistorted,validPtsDistorted] = extractFeatures(img_rl_skeleton_reference,ptsCompare);
        
        % get index pairs
        index_pairs = matchFeatures(featuresOriginal,featuresDistorted);
        
        % find matched points
        matchedPtsOriginal = validPtsOriginal(index_pairs(:,1));
        matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));
        
        % estimate the transformation based on the points
        [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'similarity');
        
        % warp reference image to original transform
        outputView = imref2d(size(img_rl_skeleton));
        Ir = imwarp(img_rl_skeleton_reference,tform,'OutputView',outputView);
        
        % add images to see effect of transformation
        comb_after = Ir + img_rl_skeleton;
        comb_before = img_rl_skeleton_reference + img_rl_skeleton;
        
        % show in RG or B
        comb_before(:,:,1) = img_rl_skeleton_reference;
        comb_before(:,:,3) = img_rl_skeleton;
        
        if DEBUG == true
            % show result before
            figure;
            subplot(1,2,1);
            imshow(comb_before);
            title('merge before transform');
            
            % show result after
            subplot(1,2,2);
            imshow(comb_after, [0 2]);
            title('merge after transform');
        end
        
        % calculate perfect match
        full_match_percentage = 100*sum(comb_after(:) == 2)/(sum(comb_after(:) == 1) + sum(comb_after(:) == 2));
        
        
        %% ================= end method specific ==============================
        % report status
        fprintf('person:%d finger:%d number:%d vs person:%d finger:%d number:%d = %d %% match\n',person_reference,finger_reference,number_reference,person,finger,number,round(full_match_percentage));
        
        % save result to matches array
        matches_array(compare, compare_with) = round(full_match_percentage);    % TODO preallocate dfor speed
    end
end

save('result_matches.mat','matches_array');


