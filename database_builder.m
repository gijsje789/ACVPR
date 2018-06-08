% finger vein recognition
clear; clc; close all;

% for progress
db_counter = 1;
% read folders (0001 to 0060 max)
imageSet = read_imageSet('0001','0002');

PERSON_COUNT = 2;               % max 60
FINGER_COUNT = 6;               % max 6
FINGER_PHOTO_COUNT = 4;         % max 4

for person = 1:PERSON_COUNT
    
    for finger = 1:FINGER_COUNT
        
        for number = 1:FINGER_PHOTO_COUNT
            
            %% read current image
            current_source_img = get_fingerImage(imageSet, person, finger, number);
            
            %% build RL skeleton
            
            % crop image
            current_source_img_cropped = cropFingerVeinImage(current_source_img);
            current_source_img_cropped = im2double(current_source_img_cropped);
            
            % variables for Gaussian filter
            sigma = 5;
            L = 2*ceil(sigma*3)+1;
            % create the PSF
            h = fspecial('gaussian', L, sigma);
            % apply the filter
            imfiltered = imfilter(current_source_img_cropped, h, 'replicate', 'conv');
            current_source_img_cropped = mat2gray(imfiltered, [0 256]);
            
            % find repeated lines method image
            fvr = ones(size(current_source_img_cropped));
            veins = repeated_line(current_source_img_cropped, fvr, 3000, 1, 17);
            
            % binarise the vein image
            md = median(veins(veins>0));
            v_repeated_line_bin = veins > md;
            
            % clean and fill (correct isolated black and white pixels)
            img_rl_clean = bwmorph(v_repeated_line_bin,'clean');
            img_rl_fill = bwmorph(img_rl_clean,'fill');
            
            % skeletonize first time
            img_rl_skel = bwmorph(img_rl_fill,'skel',inf);
            
            % open filter image
            img_rl_open = bwareaopen(img_rl_skel, 5);  % remove unconnected pixels with length X
            
            % find branchpoints & endpoints
            B = bwmorph(img_rl_open, 'branchpoints');
            E = bwmorph(img_rl_open, 'endpoints');
            [y,x] = find(E);
            B_loc = find(B);
            Dmask = false(size(img_rl_open));
            
            % find dead ends
            for k = 1:numel(x)
                D = bwdistgeodesic(img_rl_open,x(k),y(k));
                distanceToBranchPt = min(D(B_loc));
                if distanceToBranchPt < 10
                    Dmask(D < distanceToBranchPt) = true;
                end
            end
            
            % subtract dead ends
            skelD = img_rl_open - Dmask;
            
            % fill gaps
            img_filled = filledgegaps(skelD, 9);
            
            % clean and fill (correct isolated black and white pixels)
            img_rl_clean = bwmorph(img_filled,'clean');
            img_rl_result = bwmorph(img_rl_clean,'fill');
            
            % skeletonize again to optimize branchpoint detection
            img_rl_skeleton = bwmorph(img_rl_result,'skel',inf);
            
            % find branchpoints remaining and put in array
            bw1br = bwmorph(img_rl_skeleton, 'branchpoints');
            [i,j] = find(bw1br);
            branch_array_rl = [j,i];
            
            %% build MAC skeleton
            
            % image to double
            current_source_img_double = im2double(current_source_img);
            
            % evaluate difference between enhance and not enhance in report
            img_mac = enhance_finger(current_source_img_double);
            %img_mac = imresize(img_rl, 0.5);
            
            % find Lee regions (finger region)
            fvr = lee_region(img_mac,4,40);
            
            % extract veins using maximum curvature method
            v_max_curvature = miura_max_curvature(img_mac,fvr,3);
            
            % binarize the vein image
            md = median(v_max_curvature(v_max_curvature>0));
            v_max_curvature_bin = v_max_curvature > md;
            
            % skeletonize and fill gaps
            bw1 = filledgegaps(v_max_curvature_bin, 7);
            img_mac_skeleton  = bwareaopen(bw1,5);
            
            % find branchpoints remaining and put in array
            bw1br = bwmorph(img_mac_skeleton, 'branchpoints');
            [i,j] = find(bw1br);
            branch_array_mac = [j,i];
            
            %% build MEC skeleton
            
            %% find LBP features
            
            histPerPoint = createLBPofSkel(img_mac_skeleton, branch_array_mac);
            %histPerPoint = createLBPofSkel(img_rl_skeleton, branch_array_rl);
            
            
            %% fill database entry
            data{db_counter,1} = current_source_img;       % non-cropped finger image
            data{db_counter,2} = person;                   % person number
            data{db_counter,3} = finger;                   % finger number
            data{db_counter,4} = number;                   % photo number
            data{db_counter,5} = img_rl_skeleton;          % RL skeletonized
            data{db_counter,6} = img_mac_skeleton;         % MAC skeletonized
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

% save findings to database
save('database.mat','data');
