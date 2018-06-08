% input two images, and compare for similarity
clc; clear; close all;

SHOW_FIGURES = false;

% load database
load database.mat;
[data_count, ~] = size(data);

% empty matches array
matches_array = zeros(data_count,data_count);

for compare = 1:data_count
    % read all data for first database entry
        current_source_img_reference = data{compare,1};          % cropped finger image
        person_reference = data{compare,2};                      % person number
        finger_reference = data{compare,3};                      % finger number
        number_reference = data{compare,4};                      % photo number
        img_rl_skeleton_reference = data{compare,5};             % RL skeletonized
        img_mac_skeleton_reference = data{compare,6};            % MAC skeletonized
        %img_mec_skeleton_reference = data{compare,7};           % MEC skeletonized
        branch_array_rl_reference = data{compare,8};             % branchpoint array RL
        branch_array_mac_reference = data{compare,9};            % branchpoint array MAC
        %branch_array_mec_reference = data{compare,10};          % branchpoint array MEC
        %lbp_info_reference = data{compare,11};                  % local binary pattern
    
    for compare_with = 1:data_count
        
        % read all data for first database entry
        current_source_img = data{compare_with,1};          % cropped finger image
        person = data{compare_with,2};                      % person number
        finger = data{compare_with,3};                      % finger number
        number = data{compare_with,4};                      % photo number
        img_rl_skeleton = data{compare_with,5};               % RL skeletonized
        img_mac_skeleton = data{compare_with,6};              % MAC skeletonized
        %img_mec_skeleton = data{compare_with,7};              % MEC skeletonized
        branch_array_rl = data{compare_with,8};               % branchpoint array RL
        branch_array_mac = data{compare_with,9};              % branchpoint array MAC
        %branch_array_mec = data{compare_with,10};             % branchpoint array MEC
        %lbp_info = data{compare_with,11};                   % local binary pattern
        
        if SHOW_FIGURES == true
            % show individual images
            figure;
            subplot(1,2,1);
            imshow(current_source_img_reference);
            title('reference finger');
            
            % show individual images
            subplot(1,2,2);
            imshow(current_source_img);
            title(strcat('P:',num2str(person),', F:',num2str(finger),', N:',num2str(number)));
        end
        
        %% ================== select matching method =============================
        
        full_match_percentage = rl_template_matching(img_rl_skeleton_reference, img_rl_skeleton);
        %full_match_percentage = mac_template_matching(img_mac_skeleton_reference, img_mac_skeleton);
        
        %% ================= end select matching method ==========================
        % report status
        fprintf('person:%d finger:%d number:%d + person:%d finger:%d number:%d = %d %% match\n',person_reference,finger_reference,number_reference,person,finger,number,round(full_match_percentage));
        
        % save result to matches array
        matches_array(compare, compare_with) = round(full_match_percentage); 
    end
end

save('result_matches.mat','matches_array');


