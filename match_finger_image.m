% ACVPR finger vein verification
clc; clear; close all;

test_method = 'RL';
%test_method = 'MAC';
%test_method = 'MEC';
%test_method = 'LBP';

match_method = 'template';
%match_method = 'distance';

% ask user for input image
[file,path] = uigetfile('*.png');
selected_input_image = imread(file);

% get person, finger and number of selected input image
numbers = sscanf(file, '%d_%d_%d_*');

person_reference = numbers(1);
finger_reference = numbers(2);
number_reference = numbers(3);

fprintf('Processing input image...\n');

% intialize progress counter
m_counter = 0;

RL_THRESHOLD = 90;
MAC_THRESHOLD = 7.6;
MEC_THRESHOLD = 90;
LBP_THRESHOLD = 1;

%% input image to database data
%current_source_img_ref = get_fingerImage(imageSet, person, finger, number);
current_source_img_ref = selected_input_image;

% resize image for speed purposes (50%)
img_ref = imresize(im2double(current_source_img_ref), 0.5);

% build RL skeleton
[img_rl_bin_ref, branch_array_rl_ref, img_rl_skeleton, img_rl_grayscale] = RLskeletonize(img_ref);

% build MAC skeleton
[img_mac_bin_ref, branch_array_mac_ref, max_curvature_gray_ref, img_mac_skeleton] = MACskeletonize(img_ref);

% build MEC skeleton
[img_mec_bin_ref, branch_array_mec_ref, img_mec_skeleton, v_mean_curvature] = MECskeletonize(img_ref);

% print progress
fprintf('Loading database...\n');

% load database
load 'database.mat';
[data_count, ~] = size(data);
% read folders (0001 to 0060 max)
imageSet = read_imageSet('0001','0060');

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
    img_rl_skel = data{compare_with,8};                 % skel RL
    img_mac_skel = data{compare_with,9};                % skel MAC
    img_mec_skel = data{compare_with,10};               % skel MEC
    img_mac_gray = data{compare_with,11};               % gray MAC image for LBP
    
    
    
    % report matching status
    total = data_count;
    m_counter = m_counter + 1;
    fprintf('Matching: %d/%d = ',m_counter,total);

    if(~(person == person_reference && finger == finger_reference && number == number_reference))
        % matching method specific match calculator
        if strcmp(test_method,'RL')
            if strcmp(match_method, 'template')
                full_match_percentage = template_matching(img_rl_bin_ref, img_rl_bin);
            elseif strcmp(match_method, 'distance')
                full_match_percentage = distance_tr_test(img_rl_skel, img_rl_skeleton);
            end
            fprintf('%.2f%%\n',full_match_percentage);
            if full_match_percentage > RL_THRESHOLD
                figure; imshow(current_source_img);
                title(strcat('RL: person ',num2str(person),' finger ',num2str(finger),' photo ',num2str(number),' match: ',num2str(full_match_percentage),'%'))
            end
        elseif strcmp(test_method,'MAC')
            if strcmp(match_method, 'template')
                full_match_percentage = template_matching(img_mac_bin_ref, img_mac_bin);
            elseif strcmp(match_method, 'distance')
                full_match_percentage = distance_tr_test(img_mac_skel, img_mac_skeleton);
            end
            fprintf('%.2f%%\n',full_match_percentage);
            if full_match_percentage > MAC_THRESHOLD
                figure; imshow(current_source_img);
                title(strcat('MAC: person ',num2str(person),' finger ',num2str(finger),' photo ',num2str(number),' match: ',num2str(full_match_percentage),'%'))
            end
        elseif strcmp(test_method,'MEC')
            if strcmp(match_method, 'template')
                full_match_percentage = template_matching(img_mec_bin_ref, img_mec_bin);
            elseif strcmp(match_method, 'distance')
                full_match_percentage = distance_tr_test(img_mec_skel, img_mec_skeleton);
            end
            fprintf('%.2f%%\n',full_match_percentage);
            if full_match_percentage > MEC_THRESHOLD
                figure; imshow(current_source_img);
                title(strcat('MEC: person ',num2str(person),' finger ',num2str(finger),' photo ',num2str(number),' match: ',num2str(full_match_percentage),'%'))
            end
        elseif strcmp(test_method,'LBP')
            error = lbp_matching(max_curvature_gray_ref, img_mac_gray, img_mac_bin_ref, img_mac_bin);
            if error ~= -1
                fprintf('%.2f\n',error);
            else
                fprintf('0\n');
            end
            if error < LBP_THRESHOLD
                figure; imshow(current_source_img);
                title('person %d finger %d photo %d error: %d',person,finger,number,error);
            end
        else
            fprintf('invalid test method. Use RL, MAC, MEC or LBP');
        end
    else
        fprintf('Same image \n');
    end
    
end




