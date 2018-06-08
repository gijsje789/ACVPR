% input two images, and compare for similarity
clc; clear; close all;

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
        
        % show individual images
        figure;
        subplot(2,2,1);
        imshow(img_reference);
        title('reference finger');
        
        % show individual images
        subplot(2,2,2);
        imshow(img);
        title(strcat('P:',num2str(person),', F:',num2str(finger),', N:',num2str(number)));
        
        %% ================== method specific =============================
        
       
        
        
        %% ================= end method specific ==============================
        % save result to matches array
        matches_array(compare, compare_with) = 6;
    end
end

save('result_matches.mat','matches_array');


