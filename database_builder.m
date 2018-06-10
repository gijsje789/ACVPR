% finger vein recognition
clear; clc; close all;

% for progress
db_counter = 1;
% read folders (0001 to 0060 max)
imageSet = read_imageSet('0001','0060');

PERSON_COUNT = 10;              % max 60
FINGER_COUNT = 6;               % max 6
FINGER_PHOTO_COUNT = 4;         % max 4

for person = 1:PERSON_COUNT
    
    for finger = 1:FINGER_COUNT
        
        for number = 1:FINGER_PHOTO_COUNT

            % read current image
            current_source_img = get_fingerImage(imageSet, person, finger, number);
            
            %% build RL skeleton
            
            % enhance image (contrast)
            img = enhance_finger(im2double(current_source_img));
            
            % variables for Gaussian filter
            sigma = 4; L = 2*ceil(sigma*3)+1;
            h = fspecial('gaussian', L, sigma);
            img = imfilter(img, h, 'replicate', 'conv');
            
            mask_height = 4; mask_width = 20;
            [fvr, edges] = lee_region(img,mask_height,mask_width);
            
            [m,n] = size(img);
            
            for c = 1 : n
                for r = 1 : m
                    if r > edges(1,c)
                        img(1:r-1,c) = 0;
                        break
                    end
                end
            end
            
            for c = 1 : n
                for r = 1 : m
                    if r > edges(2,c)
                        img(r:m,c) = 0;
                        break
                    end
                end
            end
            
            % repeated lines method
            %fvr = ones(size(im));
            veins = repeated_line(img, fvr, 3000, 1, 17);
            
            for c = 1 : n
                for r = 1 : m
                    if r > edges(1,c)
                        veins(1:r,c) = 0;
                        break
                    end
                end
            end
            
            for c = 1 : n
                for r = 1 : m
                    if r > edges(2,c)
                        veins(r-1:m,c) = 0;
                        break
                    end
                end
            end
            
            % binarize the vein image
            md = median(veins(veins>0));
            v_repeated_line_bin = veins > md;
            
            % clean and fill (correct isolated black and white pixels)
            img_rl_clean = bwmorph(v_repeated_line_bin,'clean');
            img_rl_fill = bwmorph(img_rl_clean,'fill');
            
            % for export to database
            img_rl_bin = img_rl_fill;
            
            % skeletonize first time
            img_rl_skel = bwmorph(img_rl_fill,'skel',inf);
            
            % open filter image
            img_rl_open = bwareaopen(img_rl_skel, 10);
            
            % fill gaps smaller than 7 pixels
            img_filledgaps = filledgegaps(img_rl_open, 7);
            
            % remove dead ends shorter than 10 pixels
            skelD = removeDeadEnds(img_filledgaps, 10);
            
            % clean and fill (correct isolated black and white pixels)
            img_rl_clean = bwmorph(skelD,'clean');
            img_rl_result = bwmorph(img_rl_clean,'fill');
            
            % skeletonize again to optimize branchpoint detection
            img_rl_skeleton = bwmorph(img_rl_result,'skel',inf);
            
            % find branchpoints remaining and put in array
            bw1br = bwmorph(img_rl_skeleton, 'branchpoints');
            [i,j] = find(bw1br);
            branch_array_rl = [j,i];
            
            %% build MAC skeleton
            
            % TODO evaluate difference between enhance and not enhance in report
            img_mac = enhance_finger(im2double(current_source_img));
            %img_mac = imresize(img_rl, 0.5);
            
            % find Lee regions (finger region)
            fvr = lee_region(img_mac,4,40);
            
            % extract veins using maximum curvature method
            v_max_curvature = miura_max_curvature(img_mac,fvr,3);
            
            % binarize the vein image
            md = median(v_max_curvature(v_max_curvature>0));
            v_max_curvature_bin = v_max_curvature > md;
            
            img_mac_bin = v_max_curvature_bin;
            
            % skeletonize and fill gaps
            bw1 = filledgegaps(v_max_curvature_bin, 7);
            img_mac_skeleton  = bwareaopen(bw1,5);
            
            % find branchpoints remaining and put in array
            bw1br = bwmorph(img_mac_skeleton, 'branchpoints');
            [i,j] = find(bw1br);
            branch_array_mac = [j,i];
            
            %% build MEC skeleton
            
            %% find LBP features
            
            %lbp_info = createLBPofSkel(img_mac_skeleton, branch_array_mac);
            %lbp_info = createLBPofSkel(img_rl_skeleton, branch_array_rl);
            
            %% fill database entry
            data{db_counter,1} = current_source_img;       % non-cropped finger image
            data{db_counter,2} = person;                   % person number
            data{db_counter,3} = finger;                   % finger number
            data{db_counter,4} = number;                   % photo number
            data{db_counter,5} = img_rl_bin;               % RL binary
            data{db_counter,6} = img_mac_bin;              % MAC binary
            %data{db_counter,7} = img_mec_skeleton;         % MEC skeletonized
            data{db_counter,8} = branch_array_rl;          % branchpoint array RL
            data{db_counter,9} = branch_array_mac;         % branchpoint array MAC
            %data{db_counter,10} = branch_array_mec;        % branchpoint array MEC
            %data{db_counter,11} = lbp_info;                % local binary pattern
            
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
