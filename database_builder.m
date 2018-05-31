% finger vein recognition
clear; clc; close all;

DEBUG = false;
db_counter = 1;

imageSet = read_imageSet('0001','0005');

PERSON_COUNT = 2;   % 1 to X
FINGER_COUNT = 2;
FINGER_PHOTO_COUNT = 2;

for person = 1:PERSON_COUNT
    
    for finger = 1:FINGER_COUNT
        
        for number = 1:FINGER_PHOTO_COUNT
            
            % Gabor variables
            GaborSigma = 5;
            dF = 2.5;
            F = 0.1014;
            %(sqrt( log(2/pi))*(2^dF + 1)/(2^dF - 1)) / GaborSigma;
            % should be optimal F according to Zhang and Yang.
            
            % read comparison image
            img = get_fingerImage(imageSet, person, finger, number);
            
            % TODO test image
            %img = imread('dataset/data/0001/0001_1_1_120509-135315.png');
            
            % crop image
            img = cropFingerVeinImage(img);
            S = im2double(img);
            
            % variables for Gaussian filter
            sigma = 5;
            L = 2*ceil(sigma*3)+1;
            h = fspecial('gaussian', L, sigma);% create the PSF
            imfiltered = imfilter(S, h, 'replicate', 'conv'); % apply the filter
            S = mat2gray(imfiltered, [0 256]);
            
            % repeated lines method
            fvr = ones(size(img));
            veins = repeated_line(S, fvr, 3000, 1, 17);
            
            % Binarise the vein image
            md = median(veins(veins>0));
            v_repeated_line_bin = veins > md;
            
            se = strel('disk',1,0);
            v_repeated_line_bin = imerode(v_repeated_line_bin,se);
            
            if DEBUG == true
                % make figure for all substeps
                figure;
                
                % show RL original image
                subplot(4,3,1);
                imshow(img);
                title('original');
                
                % show RL original image
                subplot(4,3,2);
                imshow(v_repeated_line_bin);
                title('RL');
            end
            % clean and fill (correct isolated black and white pixels)
            img_rl_clean = bwmorph(v_repeated_line_bin,'clean');
            img_rl_fill = bwmorph(img_rl_clean,'fill');
            
            if DEBUG == true
                % show after correction
                subplot(4,3,3);
                imshow(img_rl_fill);
                title('clean');
            end
            % % make average eliminating loose pixels
            % img_rl_majority = bwmorph(img_rl_open,'majority');
            %
            % % show result after majority/averaging
            % subplot(5,2,5);
            % imshow(img_rl_majority);
            % title('majority');
            
            % skeletonize first time
            img_rl_skel = bwmorph(img_rl_fill,'skel',inf);
            
            if DEBUG == true
                % show skeletonized
                subplot(4,3,4);
                imshow(img_rl_skel);
                title('skeleton');
            end
            % open filter image
            img_rl_open = bwareaopen(img_rl_skel, 5);  % remove unconnected pixels with length X
            
            if DEBUG == true
                % show result after open filter
                subplot(4,3,5);
                imshow(img_rl_open);
                title('open');
            end
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
            
            if DEBUG == true
                % display dead ends
                subplot(4,3,6);
                imshow(Dmask);
                title('dead ends');
                
                % display leftover veins
                subplot(4,3,7);
                imshow(skelD);
                %hold all;
                title('new skeleton');
            end
            % filled gaps
            img_filled = filledgegaps(skelD, 7);
            
            if DEBUG == true
                subplot(4,3,8);
                imshow(img_filled);
                title('gap filled');
            end
            
            % clean and fill (correct isolated black and white pixels)
            img_rl_clean = bwmorph(img_filled,'clean');
            img_rl_result = bwmorph(img_rl_clean,'fill');
            
            % skeletonize again to optimize branchpoint detection
            img_rl_result = bwmorph(img_rl_result,'skel',inf);
            
            % find branchpoints remaining and put in array
            bw1br = bwmorph(img_rl_result, 'branchpoints');
            [i,j] = find(bw1br);
            branch_array = [j,i];
            
            if DEBUG == true
                % display result without branchpoints
                subplot(4,3,9);
                imshow(img_rl_result);
                title('new skeleton');
                
                % save to file DEBUG
                %imwrite(img_rl_result,'test2.png')
                
                % display result with branchpoints
                subplot(4,3,10);
                imshow(img_rl_result);
                hold all;
                plot(branch_array(:,1),branch_array(:,2),'o','color','cyan','linewidth',2);
                title('new skeleton with branchpoints');
                
                % result in separate figure
                figure;
                subplot(3,1,1);
                imshow(img);
                title('original');
                
                subplot(3,1,2);
                imshow(v_repeated_line_bin);
                title('RL');
                
                subplot(3,1,3);
                imshow(img_rl_result);
                hold all;
                plot(branch_array(:,1),branch_array(:,2),'o','color','cyan','linewidth',2);
                title('veins and branchpoints');
            end
            
            windowSize = 20;
            for i = 1:size(branch_array,1)
                x_min = branch_array(i,1)-windowSize;
                x_max = branch_array(i,1)+windowSize;
                y_min = branch_array(i,2)-windowSize;
                y_max = branch_array(i,2)+windowSize;
                if x_min < 1
                    x_min = 1;
                end
                if x_max > size(img_rl_result,2)
                    x_max = size(img_rl_result,2);
                end
                if y_min < 1
                    y_min = 1;
                end
                if y_max > size(img_rl_result,1)
                    y_max = size(img_rl_result,1);
                end
                
                image = veins(y_min:y_max,x_min:x_max);
                lbp_info(i,:) = extractLBPFeatures(image, 'Upright', false, 'Radius', 3);
            end
            
            ptsImage = detectSURFFeatures(img_rl_result,'MetricThreshold',1000);
            [featuresOriginal,validPtsOriginal] = extractFeatures(img_rl_result,ptsImage);
            
            data{db_counter,1} = img;                      % cropped finger image
            data{db_counter,2} = person;                   % person number
            data{db_counter,3} = finger;                   % finger number
            data{db_counter,4} = number;                   % photo number
            data{db_counter,5} = featuresOriginal;         % features
            data{db_counter,6} = validPtsOriginal;         % valid points
            data{db_counter,7} = lbp_info;                 % local binary pattern
            
            total = PERSON_COUNT*FINGER_COUNT*FINGER_PHOTO_COUNT;
            fprintf('%d/%d: done with person %d finger %d number %d\n',db_counter,total,person,finger,number);
            db_counter = db_counter + 1;
            
        end
    end
end

save('database_rl_mark.mat','data');
