% finger vein recognition
clear; clc; close all;

% counter for progress
db_counter = 1;
% read folders (0001 to 0060 max)
imageSet = read_imageSet('0001','0060');

PERSON_COUNT = 2;          % max 60
FINGER_COUNT = 6;          % max 6
FINGER_PHOTO_COUNT = 4;    % max 4
RL_SKEL = true;            % Enable RL (repeated line tracking)
MAC_SKEL_LBP = true;       % Enable MAC (maximum curvature) and LBP (local binary pattern)
MEC_SKEL = true;           % Enable MEC (mean curvature)
LBP_EN = true;             % Enable LBP (local binary pattern)

% calculate total iterations
total = PERSON_COUNT*FINGER_COUNT*FINGER_PHOTO_COUNT;
% initialize array for speed
data{total,12} = [];

for person = 1:PERSON_COUNT
    
    for finger = 1:FINGER_COUNT
        
        for number = 1:FINGER_PHOTO_COUNT

            % read current image
            current_source_img = get_fingerImage(imageSet, person, finger, number);
            
            % resize image for speed purposes (50%)
            img = imresize(im2double(current_source_img), 0.5);
            
            %% build RL skeleton
            if RL_SKEL
                [img_rl_bin, branch_array_rl] = RLskeletonize(img);
            end
            %% build MAC skeleton
            if MAC_SKEL_LBP
                [img_mac_bin, branch_array_mac, max_curvature_gray] = MACskeletonize(img);
            end
            %% build MEC skeleton
            if MEC_SKEL
                [img_mec_skeleton, branch_array_mec] = MECskeletonize(img);
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
            % (9) MAC_branch array
            % (10) MEC_branch array
            % (11) MAC grayscale for LBP (MAC_SKEL_LBP)
            
            if RL_SKEL
                data{db_counter,5} = img_rl_bin;               % RL binary
                data{db_counter,8} = branch_array_rl;          % branchpoint array RL
            end
            
            if MAC_SKEL_LBP
                data{db_counter,6} = img_mac_bin;              % MAC binary
                data{db_counter,9} = branch_array_mac;         % branchpoint array MAC
                data{db_counter,11} = max_curvature_gray;      % grayscale of veins
            end
            
            if MEC_SKEL
                data{db_counter,7} = img_mec_skeleton;         % MEC skeletonized
                data{db_counter,10} = branch_array_mec;        % branchpoint array MEC
            end

            
            %% print progress
            fprintf('DATABASE: %d/%d\n',db_counter,total);
            db_counter = db_counter + 1;
            
        end
    end
end

% delete previous database if present
db_file = fullfile(cd, 'database.mat');
delete(db_file);

% save findings to new database
save('database.mat','data');
fprintf('DATABASE: DONE\n');
