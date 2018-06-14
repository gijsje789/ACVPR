% finger vein recognition
clear; clc; close all;

% for progress
db_counter = 1;
% read folders (0001 to 0060 max)
imageSet = read_imageSet('0001','0060');

PERSON_COUNT = 2;          % max 60
FINGER_COUNT = 6;          % max 6
FINGER_PHOTO_COUNT = 4;    % max 4
RL_SKEL = true;            % Enable repeated line tracking
MAC_SKEL = true;           % Enable MAC
MEC_SKEL = true;           % Enable MEC
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
                [img_rl_bin, branch_array_rl] = RLskeletonize(img);
            end
            %% build MAC skeleton
            if MAC_SKEL
                [img_mac_bin, branch_array_mac] = MACskeletonize(img);
            end
            %% build MEC skeleton
            if MEC_SKEL
                img_mec_skeleton = MECskeletonize(img);
            end
            %% find LBP features
            if LBP_EN
                lbp_info = createLBPofSkel(current_source_img, branch_array_mac);
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
%                 data{db_counter,10} = branch_array_mec;        % branchpoint array MEC
            end
            
            if LBP_EN
                data{db_counter,11} = lbp_info;                % local binary pattern
            end
            
            %% print progress
            total = PERSON_COUNT*FINGER_COUNT*FINGER_PHOTO_COUNT;
            fprintf('DATABASE: %d/%d\n',db_counter,total);
            db_counter = db_counter + 1;
            
        end
    end
end

% delete previous database if applicable
db_file = fullfile(cd, 'database.mat');
delete(db_file);

% save findings to new database
save('database.mat','data');
fprintf('DATABASE: DONE\n');
