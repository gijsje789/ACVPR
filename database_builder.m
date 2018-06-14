% finger vein recognition
clear; clc; close all;

% for progress
db_counter = 1;
% read folders (0001 to 0060 max)
imageSet = read_imageSet('0001','0060');

PERSON_COUNT = 2;              % max 60
FINGER_COUNT = 6;               % max 6
FINGER_PHOTO_COUNT = 4;         % max 4

for person = 1:PERSON_COUNT
    
    for finger = 1:FINGER_COUNT
        
        for number = 1:FINGER_PHOTO_COUNT

            % read current image
            current_source_img = get_fingerImage(imageSet, person, finger, number);
            
            % enhance image (contrast)
            img = imresize(im2double(current_source_img), 0.5);
            
            %% build RL skeleton
            img_enhanced_rl = img;
            
            % variables for Gaussian filter
            sigma = 4; L = 2*ceil(sigma*3)+1;
            h = fspecial('gaussian', L, sigma);
            img_gauss = imfilter(img, h, 'replicate', 'conv');
            
            mask_height = 4; mask_width = 20;
            [fvr, edges] = lee_region(img_gauss,mask_height,mask_width);
            
            [m,n] = size(img);

            for col = 1:size(edges,2)
                img_gauss(1:edges(1,col), col) = 0;
                img_gauss(edges(2,col):end, col) = 0;
            end

            [img_rl_bin, branch_array_rl] = repeatedLineTracking(img_gauss, fvr);

            
%             %% build MAC skeleton
%             
%             %img_mac = imresize(img_rl, 0.5);
%             
%             img_enhanced_mac = img;
%             
%             % find Lee regions (finger region)
%             fvr = lee_region(img,4,40);
%             
%             % extract veins using maximum curvature method
%             v_max_curvature = miura_max_curvature(img,fvr,3);
%             
%             % binarize the vein image
%             md = median(v_max_curvature(v_max_curvature>0));
%             v_max_curvature_bin = v_max_curvature > md;
%             
%             img_mac_bin = v_max_curvature_bin;
%             
%             % skeletonize and fill gaps
%             bw1 = filledgegaps(v_max_curvature_bin, 7);
%             img_mac_skeleton  = bwareaopen(bw1,5);
%             
%             % find branchpoints remaining and put in array
%             bw1br = bwmorph(img_mac_skeleton, 'branchpoints');
%             [i,j] = find(bw1br);
%             branch_array_mac = [j,i];
%             
%             %% build MEC skeleton
%             
%             %% find LBP features
%             
%             lbp_info = createLBPofSkel(img_enhanced_mac, branch_array_mac);
%             %lbp_info = createLBPofSkel(img_enhanced_rl, branch_array_rl);
            
            %% fill database entry
            data{db_counter,1} = current_source_img;       % non-cropped finger image
            data{db_counter,2} = person;                   % person number
            data{db_counter,3} = finger;                   % finger number
            data{db_counter,4} = number;                   % photo number
            data{db_counter,5} = img_rl_bin;               % RL binary
%             data{db_counter,6} = img_mac_bin;              % MAC binary
            %data{db_counter,7} = img_mec_skeleton;         % MEC skeletonized
            data{db_counter,8} = branch_array_rl;          % branchpoint array RL
%             data{db_counter,9} = branch_array_mac;         % branchpoint array MAC
            %data{db_counter,10} = branch_array_mec;        % branchpoint array MEC
%             data{db_counter,11} = lbp_info;                % local binary pattern
            
            %% print progress
            total = PERSON_COUNT*FINGER_COUNT*FINGER_PHOTO_COUNT;
            %fprintf('%d/%d: done with person %d finger %d number %d\n',db_counter,total,person,finger,number);
            fprintf('DATABASE: %d/%d\n',db_counter,total);
            db_counter = db_counter + 1;
            
        end
    end
end

% delete previous database
db_file = fullfile(cd, 'database.mat');
delete(db_file);

% save findings to new database
save('database.mat','data');
fprintf('DATABASE: DONE\n');
