% input two images, and compare for similarity
clc; clear; close all;

% load database
load database_rl.mat;
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
    %img_rl_reference = data{compare,9};                      % RL image for template matching
    
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
        %img_rl = data{compare_with,9};                      % RL image for template matching
        
        % show individual images
        figure;
        subplot(2,2,1);
        imshow(img_reference);
        title('reference finger');
        
        % show individual images
        subplot(2,2,2);
        imshow(img);
        title(strcat('P:',num2str(person),', F:',num2str(finger),', N:',num2str(number)));
        
        %%================== method specific =============================
        im_reference = im2double(img_reference); % Read the image
            
        im_to_compare = im2double(img);
        
        for iteration = 1:2
                
                % alternate between original and comparing image
                if iteration == 1
                    img_rl = im_to_compare;
                else
                    img_rl = im_reference;
                end
                
            %img = enhance_finger(img_rl);
            img = imresize(img_rl, 0.5);
            
            fvr = lee_region(img,4,40);    % Get finger region

            % Extract veins using maximum curvature method
            sigma = 3; % Parameter
            v_max_curvature = miura_max_curvature(img,fvr,sigma);

            % Binarise the vein image
            md = median(v_max_curvature(v_max_curvature>0));
            v_max_curvature_bin = v_max_curvature > md;
            img = v_max_curvature_bin;

            bw1 = filledgegaps(img, 7);
            img_rl_result  = bwareaopen(bw1,5);
                
                
                % alternate between original and comparing image
                if iteration == 1
                    im_to_compare = img_rl_result;
                else
                    im_reference = img_rl_result;
                end
                
            end
            
            % detect surface features of both
            ptsOriginal  = detectSURFFeatures(im_to_compare,'MetricThreshold',1000);
            ptsCompare = detectSURFFeatures(im_reference,'MetricThreshold',1000);
            
            % read features and valid points
            [featuresOriginal,validPtsOriginal] = extractFeatures(im_to_compare,ptsOriginal);
            [featuresDistorted,validPtsDistorted] = extractFeatures(im_reference,ptsCompare);
            
            % get index pairs
            index_pairs = matchFeatures(featuresOriginal,featuresDistorted);
            
            % find matched points
            matchedPtsOriginal = validPtsOriginal(index_pairs(:,1));
            matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));
            
            % show all matched points
            %subplot(2,3,3);
            %showMatchedFeatures(im_to_compare,im_reference,matchedPtsOriginal,matchedPtsDistorted);
            %title('Matched points including outliers');
            
            % estimate the transformation based on the points
            [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'similarity');
            
            % show useful matched points
            %subplot(2,3,4);
            %showMatchedFeatures(im_to_compare,im_reference,inlierPtsOriginal,inlierPtsDistorted);
            %title('Matching points (inliers only)');
            
            % warp compare image to original transform
            outputView = imref2d(size(im_to_compare));
            Ir = imwarp(im_reference,tform,'OutputView',outputView);
            
            % add images to see effect of transformation
            comb_after = Ir + im_to_compare;
            comb_before = im_reference + im_to_compare;
            
            % show in RG or B for clarification
            comb_before(:,:,1) = im_reference;
            comb_before(:,:,3) = im_to_compare;
            
            % show result before
            %subplot(2,3,5);
            %imshow(comb_before);
            %title('Merge before transform');
            
            % calculate match
            full_match_percentage = 100*sum(comb_after(:) == 2)/(sum(comb_after(:) == 1) + sum(comb_after(:) == 2));
            
            % show result after
            %subplot(2,3,6);
            %imshow(comb_after, [0 2]);
            %title(strcat('Merge after transform (',num2str(round(full_match_percentage)),'% match)'));
            
            % if more than 5% similarity, it can be considered a match
            if full_match_percentage > 5
                %hold on;
                %plot(336,1,'o','linewidth',7,'color','green');
                fprintf(strcat('MATCH WITH person:',num2str(person),' finger:',num2str(finger),' number:',num2str(number),'!\n'));
            else
                %hold on;
                %plot(336,1,'o','linewidth',7,'color','red');
            end

        
        %%================= end method specific ==============================
        % save result to matches array
        matches_array(compare, compare_with) = round(full_match_percentage);
    end
end

save('result_matches.mat','matches_array');


