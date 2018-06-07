% input two images, and compare for similarity
clc; clear; close all;

% load database
load database_rl.mat;
[data_count, ~] = size(data);

% image to compare with all in database
im_reference = data{4,1};

for compare_with = 1:data_count    % TODO give maximum
    
            img = data{compare_with,1};                           % cropped finger image
            person = data{compare_with,2};                        % person number
            finger = data{compare_with,3};                        % finger number
            number = data{compare_with,4};                        % photo number
            featuresOriginal = data{compare_with,5};              % features
            validPtsOriginal = data{compare_with,6};              % valid points
            lbp_info = data{compare_with,7};                      % local binary pattern
            branch_array = data{compare_with,8};                  % branchpoint array
            
            % show individual images
            figure;
            subplot(2,2,1);
            imshow(im_reference);
            title('reference finger');
            
            subplot(2,2,2);
            imshow(img);
            %title('person %d finger %d number %d\n',person,finger,number);
            title(strcat('P:',num2str(person),', F:',num2str(finger),', N:',num2str(number)));
            
end




