% finger vein recognition
clear; clc; close all;

% for progress
db_counter = 1;
% read folders (0001 to 0060 max)
imageSet = read_imageSet('0001','0060');

PERSON_COUNT = 2;              % max 60
FINGER_COUNT = 6;               % max 6
FINGER_PHOTO_COUNT = 4;         % max 4
RL_SKEL = true;            % Enable repeated line tracking
MAC_SKEL = true;            % Enable MAC
MEC_SKEL = false;           % Enable MEC
LBP_EN = true;             % Enable LBP


for person = 1:PERSON_COUNT
    
    for finger = 1:FINGER_COUNT
        
        for number = 1:FINGER_PHOTO_COUNT

            % read current image
            current_source_img = get_fingerImage(imageSet, person, finger, number);
            
            % enhance image (contrast)
            img = imresize(im2double(current_source_img), 0.5);
            
            %% build RL skeleton
            if RL_SKEL
                tic
                [img_rl_bin, branch_array_rl] = RLskeletonize(img);
                toc
            end
            
            %% build MAC skeleton
            if MAC_SKEL
                tic
                [img_mac_bin, branch_array_mac] = MACskeletonize(img);
                toc
            end
            %% build MEC skeleton
            if MEC_SKEL
                % Tested using enhance; did not improve results. 
                %ima = adapthisteq(image);
                %image = enhance_finger(current_source_img);
                image = imresize(im2double(current_source_img), 0.5);
                %image = current_source_img;

                mask_height=4; % Height of the mask
                mask_width=20; % Width of the mask
                [fvr, edges] = lee_region(image,mask_height,mask_width);
                x = 1: 1 : length(edges(2,:));

                [m,n] = size(image);

                for c = 1 : n
                    for r = 1 : m
                        if r > edges(1,c)
                           image(1:r-1,c) = 0; 
                           break
                        end
                    end
                end

                for c = 1 : n
                    for r = 1 : m
                        if r > edges(2,c)
                           image(r:m,c) = 0; 
                           break
                        end
                    end
                end

                % gaussian filter

                S= im2double(image);

                sigma = 3.2;
                L = 2*ceil(sigma*3)+1;
                h = fspecial('gaussian', L, sigma);% create the PSF
                imfiltered = imfilter(S, h, 'replicate', 'conv'); % apply the filter

                S = imfiltered;%mat2gray(imfiltered, [0 256]);

                % Mean curvature method

                v_mean_curvature = mean_curvature(S);

                % Binarise the vein image
                md = 0.01;
                img_mec_bin = v_mean_curvature > md; 


                bw1 = filledgegaps(img_mec_bin, 7);
                img_mec_skeleton  = bwareaopen(bw1,10);
            end
            %% find LBP features
            if LBP_EN
                tic
                lbp_info = createLBPofSkel(img_enhanced_mac, branch_array_mac);
                toc
            end
            %% fill database entry
            data{db_counter,1} = current_source_img;       % non-cropped finger image
            data{db_counter,2} = person;                   % person number
            data{db_counter,3} = finger;                   % finger number
            data{db_counter,4} = number;                   % photo number

            % (5) RL_SKEL
            % (6) MAC_SKEL
            % (7) MEC_SKEL
            % (8) RL_branch array
            % (9) MAC branch array
            % (10) MEC branch array
            % (11) LBP info
            
            if RL_SKEL
                data{db_counter,5} = img_rl_bin;               % RL binary
                data{db_counter,8} = branch_array_rl;          % branchpoint array RL
            end
            
            if MAC_SKEL
                data{db_counter,6} = img_mac_bin;              % MAC binary
                data{db_counter,9} = branch_array_mac;         % branchpoint array MAC
            end
            
            if MEC_SKEL
                data{db_counter,7} = img_mec_skeleton;         % MEC skeletonized
                data{db_counter,10} = branch_array_mec;        % branchpoint array MEC
            end
            
            if LBP_EN
                data{db_counter,11} = lbp_info;                % local binary pattern
            end
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
