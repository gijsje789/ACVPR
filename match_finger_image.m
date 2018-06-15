% ACVPR finger vein verification
clc; clear; close all;

%test_method = 'RL';
test_method = 'MAC';
%test_method = 'MEC';
%test_method = 'LBP';

% load database
load 'database - full.mat';
[data_count, ~] = size(data);
% read folders (0001 to 0060 max)
imageSet = read_imageSet('0001','0060');

% intialize progress counter
m_counter = 1;

% TODO change to input image
person = 1;
finger = 1;
number = 1;

RL_THRESHOLD = 0;
MAC_THRESHOLD = 7.6;
MEC_THRESHOLD = 0;
LBP_THRESHOLD = 0;

%% input image to database data
% read current image
current_source_img = get_fingerImage(imageSet, person, finger, number);

% resize image for speed purposes (50%)
img = imresize(im2double(current_source_img), 0.5);

% build RL skeleton
[img_rl_bin, branch_array_rl] = RLskeletonize(img);

% build MAC skeleton
[img_mac_bin, branch_array_mac, max_curvature_gray] = MACskeletonize(img);

% build MEC skeleton
[img_mec_skeleton, branch_array_mec] = MECskeletonize(img);

%% match with other database entries

for compare_with = 1:data_count
    
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
    if strcmp(test_method,'RL')
        full_match_percentage = template_matching(img_rl_bin, img_rl_bin);
    elseif strcmp(test_method,'MAC')
        full_match_percentage = template_matching(img_mac_bin, img_mac_bin);
    elseif strcmp(test_method,'MEC')
        full_match_percentage = template_matching(img_mec_skeleton, img_mec_bin);
    elseif strcmp(test_method,'LBP')
        error = lbp_matching(max_curvature_gray, img_mac_gray, img_mac_bin, img_mac_bin);
    else
        fprintf('invalid test method. Use RL, MAC, MEC or LBP');
    end
    
    % report matching status
    total = data_count^2;
    fprintf('MATCHING: %d/%d = ',m_counter,total);
    m_counter = m_counter + 1;
    
    if strcmp(test_method,'RL') || strcmp(test_method,'MAC') || strcmp(test_method,'MEC')
        fprintf('%.2f%% MATCH\n',full_match_percentage);
    elseif strcmp(test_method,'LBP')
        if error ~= -1
            fprintf('%.2f ERROR\n',error);
        else
            fprintf('0%% MATCH\n');
        end
    else
        fprintf('SELECT METHOD\n');
    end
    
    
    if strcmp(test_method,'RL') && full_match_percentage > RL_THRESHOLD
        
    elseif strcmp(test_method,'MAC') && full_match_percentage > MAC_THRESHOLD
        figure; imshow(current_source_img);
        title('person %d finger %d photo %d match: %.2f%%',person,finger,number,full_match_percentage);
    elseif strcmp(test_method,'MEC') && full_match_percentage > MEC_THRESHOLD
         
    elseif strcmp(test_method,'LBP') && error < LBP_THRESHOLD
        
    end
    
end




