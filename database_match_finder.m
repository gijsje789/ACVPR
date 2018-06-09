% input two images, and compare for similarity
clc; clear; close all;

% intialize counter 
m_counter = 1;

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
    img_rl_bin_reference = data{compare,5};             % RL binary
    img_mac_bin_reference = data{compare,6};            % MAC binary
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
        img_rl_bin = data{compare_with,5};               % RL binary
        img_mac_bin = data{compare_with,6};              % MAC binary
        %img_mec_skeleton = data{compare_with,7};              % MEC skeletonized
        branch_array_rl = data{compare_with,8};               % branchpoint array RL
        branch_array_mac = data{compare_with,9};              % branchpoint array MAC
        %branch_array_mec = data{compare_with,10};             % branchpoint array MEC
        %lbp_info = data{compare_with,11};                   % local binary pattern
        
        %% ================== select matching method =============================
        
        %full_match_percentage = template_matching(img_rl_bin_reference, img_rl_bin);
        full_match_percentage = template_matching(img_mac_bin_reference, img_mac_bin);
        
        %% ================= end select matching method ==========================
        
        % report matching status
        total = data_count*data_count;
        fprintf('MATCHING: %d/%d\n',m_counter,total);
        m_counter = m_counter + 1;
        
         % round percentage
        %full_match_percentage = round(full_match_percentage);
        %full_match_percentage = round(full_match_percentage,2);
        
        % save result to matches array
        matches_array(compare, compare_with) = full_match_percentage;
    end
end

% save to file
save('result_matches.mat','matches_array');

% calculate EER, print result and show graph, 
% DO NOT ROUND "FULLMATCHPERCENTAGE" FOR ACCURATE EER
EER = calculate_EER(matches_array);
fprintf('EER: %.2f %%\n',EER);



