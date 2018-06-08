% finger vein recognition
clear; clc; close all;

% for progress
db_counter = 1;
% read folders
imageSet = read_imageSet('0001','0060');

PERSON_COUNT = 60;   % 1 to X
FINGER_COUNT = 6;    % max 6
FINGER_PHOTO_COUNT = 4;     % max 4

for person = 1:PERSON_COUNT
    
    for finger = 1:FINGER_COUNT
        
        for number = 1:FINGER_PHOTO_COUNT
            
            %% read current image
            img = get_fingerImage(imageSet, person, finger, number);
            
            %% build RL skeleton
            % Gabor variables
            GaborSigma = 5; dF = 2.5; F = 0.1014;
            
            % crop image
            img = cropFingerVeinImage(img);
            S = im2double(img);
            
            % variables for Gaussian filter
            sigma = 5;
            L = 2*ceil(sigma*3)+1;
            h = fspecial('gaussian', L, sigma);% create the PSF
            imfiltered = imfilter(S, h, 'replicate', 'conv'); % apply the filter
            S = mat2gray(imfiltered, [0 256]);
            
            % find repeated lines method image
            fvr = ones(size(img));
            veins = repeated_line(S, fvr, 3000, 1, 17);
            
            % Binarise the vein image
            md = median(veins(veins>0));
            v_repeated_line_bin = veins > md;
            
            se = strel('disk',1,0);
            v_repeated_line_bin = imerode(v_repeated_line_bin,se);
            
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
            branch_array = [j,i];
            
            %% build MC skeleton
            
            %% find LBP features
            
%             windowSize = 20;
%             for i = 1:size(branch_array,1)
%                 x_min = branch_array(i,1)-windowSize;
%                 x_max = branch_array(i,1)+windowSize;
%                 y_min = branch_array(i,2)-windowSize;
%                 y_max = branch_array(i,2)+windowSize;
%                 if x_min < 1
%                     x_min = 1;
%                 end
%                 if x_max > size(img_rl_skeleton,2)
%                     x_max = size(img_rl_skeleton,2);
%                 end
%                 if y_min < 1
%                     y_min = 1;
%                 end
%                 if y_max > size(img_rl_skeleton,1)
%                     y_max = size(img_rl_skeleton,1);
%                 end
%                 
%                 image = veins(y_min:y_max,x_min:x_max);
%                 lbp_info(i,:) = extractLBPFeatures(image, 'Upright', false, 'Radius', 3);
%             end
%              
          
            
            %% build data array
            data{db_counter,1} = img;                      % cropped finger image
            data{db_counter,2} = person;                   % person number
            data{db_counter,3} = finger;                   % finger number
            data{db_counter,4} = number;                   % photo number
            data{db_counter,5} = featuresOriginal;         % features
            data{db_counter,6} = validPtsOriginal;         % valid points
            data{db_counter,7} = lbp_info;                 % local binary pattern
            data{db_counter,8} = branch_array;             % branchpoint array
            data{db_counter,9} = img_rl_skeleton;          % RL skeletonized
            
            %% print progress
            total = PERSON_COUNT*FINGER_COUNT*FINGER_PHOTO_COUNT;
            fprintf('%d/%d: done with person %d finger %d number %d\n',db_counter,total,person,finger,number);
            db_counter = db_counter + 1;
            
        end
    end
end

% save findings to database
save('database.mat','data');
