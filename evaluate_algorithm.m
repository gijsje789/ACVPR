% ACVPR finger vein verification
clc; clear; close all;

% test_method = 'RL';
 test_method = 'MAC';
% test_method = 'MEC';
%test_method = 'LBP';

PEOPLE_COUNT = 2;    % max 60

% load database
load 'database.mat';
[data_count, ~] = size(data);

% empty matches array
matches_array = zeros(PEOPLE_COUNT*24,PEOPLE_COUNT*24);

% intialize progress counter
m_counter = 1;

for compare = 1:PEOPLE_COUNT*24
    % read all data for first database entry
    current_source_img_reference = data{compare,1};          % original finger image
    person_reference = data{compare,2};                      % person number
    finger_reference = data{compare,3};                      % finger number
    number_reference = data{compare,4};                      % photo number
    img_rl_bin_reference = data{compare,5};                  % RL binary
    img_mac_bin_reference = data{compare,6};                 % MAC binary
    img_mec_bin_reference = data{compare,7};                 % MEC binary
    branch_array_rl_reference = data{compare,8};             % branchpoint array RL
    branch_array_mac_reference = data{compare,9};            % branchpoint array MAC
    branch_array_mec_reference = data{compare,10};           % branchpoint array MEC
    img_mac_gray_reference = data{compare,11};               % gray MAC image for LBP
    
    for compare_with = 1:PEOPLE_COUNT*24
        
        % read all data for first database entry
        current_source_img = data{compare_with,1};          % original finger image
        person = data{compare_with,2};                      % person number
        finger = data{compare_with,3};                      % finger number
        number = data{compare_with,4};                      % photo number
        img_rl_bin = data{compare_with,5};                  % RL binary
        img_mac_bin = data{compare_with,6};                 % MAC binary
        img_mec_bin = data{compare_with,7};                 % MEC binary
        branch_array_rl = data{compare_with,8};             % branchpoint array RL
        branch_array_mac = data{compare_with,9};            % branchpoint array MAC
        branch_array_mec = data{compare_with,10};           % branchpoint array MEC
        img_mac_gray = data{compare_with,11};               % gray MAC image for LBP
        
        % matching method specific actions
        if(~(person == person_reference && finger == finger_reference && number == number_reference))
            if strcmp(test_method,'RL')
                full_match_percentage = template_matching(img_rl_bin_reference, img_rl_bin);
            elseif strcmp(test_method,'MAC')
                full_match_percentage = template_matching(img_mac_bin_reference, img_mac_bin);
            elseif strcmp(test_method,'MEC')
                full_match_percentage = template_matching(img_mec_bin_reference, img_mec_bin);
            elseif strcmp(test_method,'LBP')
                error = lbp_matching(img_mac_gray_reference, img_mac_gray, img_mac_bin_reference, img_mac_bin);
                if error ~= -1
                    matches_array(compare,compare_with) = error;
                end
            else
                fprintf('invalid test method. Use RL, MAC, MEC or LBP');
            end
        else
            full_match_percentage = -1;
            error = -1;
        end

        if strcmp(test_method,'RL') || strcmp(test_method,'MAC') || strcmp(test_method,'MEC')
            % save result to matches array
            matches_array(compare, compare_with) = full_match_percentage;
        end
        
        % report matching status
        total = (PEOPLE_COUNT*24)^2;
        fprintf('MATCHING: %d/%d\n',m_counter,total);
        m_counter = m_counter + 1;
    end
end

% for LBP find range and fill matches array
if strcmp(test_method,'LBP')
    max = mean(median(matches_array));
    matches_array(matches_array > max) = max;
    matches_array = 100-(matches_array./max.*100);
    matches_array(1:1+size(matches_array,1):end) = -1;
end

% save to matrix file and excel file
save('vein_matching_results.mat','matches_array');
%xlswrite('vein_matching_results.xls',matches_array); 

% calculate EER, print result and show EER graph
[EER, EERthreshold] = calculate_EER(matches_array);
fprintf('EER = %.2f%% (OPTIMAL THRESHOLD = %.2f%%)\n',EER, EERthreshold);


