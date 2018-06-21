% finger vein recognition
clear; clc; close all;

load('database_maikel.mat')

% for progress
db_counter = 1;
% read folders (0001 to 0060 max)
imageSet = read_imageSet('0001','0002');

PERSON_COUNT = 2;               % max 60
FINGER_COUNT = 6;               % max 6
FINGER_PHOTO_COUNT = 4;         % max 4

SHOW_FIGURES = false;

for person = 1:PERSON_COUNT
    
    for finger = 1:FINGER_COUNT
        
        for number = 1:FINGER_PHOTO_COUNT
            
            
            
            img = get_fingerImage(imageSet, person, finger, number);
            
    img = enhance_finger(im2double(img));
    
    % variables for Gaussian filter
    sigma = 4; L = 2*ceil(sigma*3)+1;
    h = fspecial('gaussian', L, sigma);
    img = imfilter(img, h, 'replicate', 'conv');
    
    if SHOW_FIGURES == true
        figure;
        imshow(img);
        title('after Gaussian');
    end
    
    mask_height = 4; mask_width = 20; 
    [fvr, edges] = lee_region(img,mask_height,mask_width);
    %x = 1: 1 : length(edges(2,:));
    
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
    
    if SHOW_FIGURES == true
        figure;
        imshow(veins);
        title('RL veins');
    end
    
    % Binarise the vein image
    md = median(veins(veins>0));
    v_repeated_line_bin = veins > md;
    
    if SHOW_FIGURES == true
        figure;
        imshow(v_repeated_line_bin);
        title('RL veins bin');
    end
    
    img = v_repeated_line_bin;
    
    % resize image according to the paper
    size(img);
    img_conv = conv2(img,[1,1,1;1,1,1],'valid');
    img = img_conv(1:3:end,1:3:end)/6;
    
    if SHOW_FIGURES == true
        figure;
        imshow(img);
        title('resized image');
    end
    
    thresh = multithresh(img,2);
    img_rl_result = imquantize(img,thresh);
    
    if SHOW_FIGURES == true
        figure;
        imshow(img,[]);
        title('3 thresholded image');
    end
    
%    img = img > 1;
    
%     % clean and fill (correct isolated black and white pixels)
%     img_rl_clean = bwmorph(img,'clean');
%     img_rl_result = bwmorph(img_rl_clean,'fill');
%     
%     if SHOW_FIGURES == true
%         figure;
%         imshow(img_rl_fill);
%         title('cleaned filled');
%     end
    
%     % skeletonize first time
%     img_rl_skel = bwmorph(img_rl_fill,'skel',inf);
%     
%     if SHOW_FIGURES == true
%         figure;
%         imshow(img_rl_skel);
%         title('skeletonized');
%     end
%     
%     % open filter image
%     img_rl_open = bwareaopen(img_rl_skel, 10);
%     
%     img_filledgaps = filledgegaps(img_rl_open, 7);
%     
%     if SHOW_FIGURES == true
%         figure;
%         imshow(img_filledgaps);
%         title('opened + fg');
%     end
%     
%     % find branchpoints & endpoints
%     B = bwmorph(img_filledgaps, 'branchpoints');
%     E = bwmorph(img_filledgaps, 'endpoints');
%     
%     [y,x] = find(E);
%     B_loc = find(B);
%     
%     Dmask = false(size(img_filledgaps));
%     
%     % find dead ends
%     for i = 1:numel(x)
%         D = bwdistgeodesic(img_filledgaps,x(i),y(i));
%         distanceToBranchPt = min(D(B_loc));
%         if distanceToBranchPt < 10
%             Dmask(D < distanceToBranchPt) = true;
%         end
%     end
%     
%     % subtract dead ends
%     skelD = img_filledgaps - Dmask;
%     
%     if SHOW_FIGURES == true
%         figure;
%         imshow(skelD);
%         title('dead ends gone');
%     end
%     
%     % clean and fill (correct isolated black and white pixels)
%     img_rl_clean = bwmorph(skelD,'clean');
%     img_rl_result = bwmorph(img_rl_clean,'fill');
%     
%     if SHOW_FIGURES == true
%         figure;
%         imshow(img_rl_result);
%         title('cleaned');
%     end
%     
%     % skeletonize again to optimize branchpoint detection
%     img_rl_result = bwmorph(img_rl_result,'skel',inf);
            
%             % read current image
%             current_source_img = get_fingerImage(imageSet, person, finger, number);
%             
% %                
%             % TODO evaluate difference between enhance and not enhance in report
%             %img_mac = enhance_finger(im2double(current_source_img));
%             img_mac = im2double(imresize(current_source_img, 0.5));
%             
%             S= im2double(img_mac);
% 
%             sigma = 3.2;
%             L = 2*ceil(sigma*3)+1;
%             h = fspecial('gaussian', L, sigma);% create the PSF
%             imfiltered = imfilter(S, h, 'replicate', 'conv'); % apply the filter
% 
%             S = imfiltered;%mat2gray(imfiltered, [0 256]);
% 
%             
%             % find Lee regions (finger region)
%             fvr = lee_region(S,4,40);
%             
%             % extract veins using maximum curvature method
%             v_max_curvature = miura_max_curvature(S,fvr,3);
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

       
            %% build MEC skeleton
            
%             %% find LBP features
%             
%             lbp_info = createLBPofSkel(img_mac_skeleton, branch_array_mac);
%             %lbp_info = createLBPofSkel(img_rl_skeleton, branch_array_rl);
%             
            %% fill database entry
%             data{db_counter,1} = current_source_img;       % non-cropped finger image
%             data{db_counter,2} = person;                   % person number
%             data{db_counter,3} = finger;                   % finger number
%             data{db_counter,4} = number;                   % photo number
%             data{db_counter,5} = img_rl_skeleton;          % RL skeletonized
             %data{db_counter,6} = img_mac_skeleton;         % MAC skeletonized
%             %data{db_counter,7} = img_mec_skeleton;         % MEC skeletonized
%             data{db_counter,8} = branch_array_rl;          % branchpoint array RL
%             data{db_counter,9} = branch_array_mac;         % branchpoint array MAC
%             %data{db_counter,10} = branch_array_mec;        % branchpoint array MEC
%             data{db_counter,11} = lbp_info;                % local binary pattern
            data{db_counter,9} = img_rl_result;                % local binary pattern
            
            %% print progress
            total = PERSON_COUNT*FINGER_COUNT*FINGER_PHOTO_COUNT;
            %fprintf('%d/%d: done with person %d finger %d number %d\n',db_counter,total,person,finger,number);
            fprintf('DATABASE: %d/%d\n',db_counter,total);
            db_counter = db_counter + 1;
            
        end
    end
end

% save findings to database
save('database_maikel.mat','data');
