% ACVPR finger vein verification
clc; clear; close all;

%test_method = 'RL';
test_method = 'MAC';
%test_method = 'MEC';
%test_method = 'LBP';

%match_method = 'template';
match_method = 'distance';

% select start and stop entry from database to evaluate; range depends on database size
START_ENTRY = 6;        
STOP_ENTRY = 8;       

% load database
load 'database.mat';
[data_count, ~] = size(data);

% empty matches array
matches_array = zeros((1 + STOP_ENTRY - START_ENTRY),(1 + STOP_ENTRY - START_ENTRY));

% intialize progress counter
m_counter = START_ENTRY;

for compare = START_ENTRY:STOP_ENTRY
    
    % read all data for first database entry
    current_source_img_reference = data{compare,1};          % original finger image
    person_reference = data{compare,2};                      % person number
    finger_reference = data{compare,3};                      % finger number
    number_reference = data{compare,4};                      % photo number
    img_rl_bin_reference = data{compare,5};                  % RL binary
    img_mac_bin_reference = data{compare,6};                 % MAC binary
    img_mec_bin_reference = data{compare,7};                 % MEC binary
    img_rl_skel_reference = data{compare,8};                 % branchpoint array RL
    img_mac_skel_reference = data{compare,9};                % branchpoint array MAC
    img_mec_skel_reference = data{compare,10};               % branchpoint array MEC
    img_mac_gray_reference = data{compare,11};               % gray MAC image for LBP
    img_rl_gray_reference = data{compare,12};                % gray RL image or LBP
    img_mec_gray_reference = data{compare,13};               % gray MEC image for LBP
    mac_lbp_reference = data{compare,14};                    % mac lbp
    rl_lbp_reference = data{compare,15};                     % rl lbp
    mec_lbp_reference = data{compare,16};                    % mec lbp
    
    for compare_with = START_ENTRY:STOP_ENTRY
        
        % read all data for first database entry
        current_source_img = data{compare_with,1};          % original finger image
        person = data{compare_with,2};                      % person number
        finger = data{compare_with,3};                      % finger number
        number = data{compare_with,4};                      % photo number
        img_rl_bin = data{compare_with,5};                  % RL binary
        img_mac_bin = data{compare_with,6};                 % MAC binary
        img_mec_bin = data{compare_with,7};                 % MEC binary
        img_rl_skel = data{compare_with,8};                 % branchpoint array RL
        img_mac_skel = data{compare_with,9};                % branchpoint array MAC
        img_mec_skel = data{compare_with,10};               % branchpoint array MEC
        img_mac_gray = data{compare_with,11};               % gray MAC image for LBP
        img_rl_gray = data{compare_with,12};                % gray RL image or LBP
        img_mec_gray = data{compare_with,13};               % gray MEC image for LBP
        mac_lbp = data{compare_with,14};                    % mac lbp
        rl_lbp = data{compare_with,15};                     % rl lbp
        mec_lbp = data{compare_with,16};                    % mec lbp
        
        % matching method specific actions
        if(~(person == person_reference && finger == finger_reference && number == number_reference))
            if strcmp(test_method,'RL')
                if strcmp(match_method, 'template')
                    full_match_percentage = template_matching(img_rl_bin_reference, img_rl_bin);
                elseif strcmp(match_method, 'distance')
                    full_match_percentage = distance_tr_test(img_rl_skel_reference, img_rl_skel);
                end
            elseif strcmp(test_method,'MAC')
                if strcmp(match_method, 'template')
                    full_match_percentage = template_matching(img_mac_bin_reference, img_mac_bin);
                elseif strcmp(match_method, 'distance')
                    full_match_percentage = distance_tr_test(img_mac_skel_reference, img_mac_skel);
                end
            elseif strcmp(test_method,'MEC')
                if strcmp(match_method, 'template')
                    full_match_percentage = template_matching(img_mec_bin_reference, img_mec_bin);
                elseif strcmp(match_method, 'distance')
                    full_match_percentage = distance_tr_test(img_mec_skel_reference, img_mec_skel);
                end
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
        total = (1 + STOP_ENTRY - START_ENTRY)^2;
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
[EER, EERthreshold, ROC] = calculate_EERorROC(matches_array, 'showEER', 'showROC');
fprintf('EER = %.2f%% (OPTIMAL THRESHOLD = %.2f%%)\nROC = %.2f%%\n',EER, EERthreshold, ROC);


