% input two images, and compare for similarity
clc; clear; close all;

% load database
load database_rl.mat;
[data_count, ~] = size(data);

% empty matches array
matches_array = [];

for compare = 1:data_count
    % read all data for first database entry
    img_reference = data{compare,1};                         % cropped finger image
    person_reference = data{compare,2};                      % person number
    finger_reference = data{compare,3};                      % finger number
    number_reference = data{compare,4};                      % photo number
    featuresOriginal_reference = data{compare,5};            % features
    validPtsOriginal_reference = data{compare,6};            % valid points
    lbp_info_reference = data{compare,7};                    % local binary pattern
    branch_array_reference = data{compare,8};                % branchpoint array
    
    for compare_with = 1:data_count
        
        % read all data for first database entry
        img = data{compare_with,1};                         % cropped finger image
        person = data{compare_with,2};                      % person number
        finger = data{compare_with,3};                      % finger number
        number = data{compare_with,4};                      % photo number
        featuresOriginal = data{compare_with,5};            % features
        validPtsOriginal = data{compare_with,6};            % valid points
        lbp_info = data{compare_with,7};                    % local binary pattern
        branch_array = data{compare_with,8};                % branchpoint array
        
        % show individual images
        figure;
        subplot(2,2,1);
        imshow(img_rl_reference);
        title('reference finger');
        
        % show individual images
        subplot(2,2,2);
        imshow(img_rl);
        title(strcat('P:',num2str(person),', F:',num2str(finger),', N:',num2str(number)));
        
        %% ================== method specific =============================
        
        % Gabor variables
        GaborSigma = 5;
        dF = 2.5;
        F = 0.1014;
        %(sqrt( log(2/pi))*(2^dF + 1)/(2^dF - 1)) / GaborSigma;
        % should be optimal F according to Zhang and Yang.
        
        % TODO test image
        img = imread('dataset/data/0001/0001_1_1_120509-135315.png');
        
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
        
        % make figure for all substeps
        figure;
        
        % show RL original image
        subplot(4,2,1);
        imshow(img);
        title('original');
        
        % show RL original image
        subplot(4,2,2);
        imshow(v_repeated_line_bin);
        title('RL');
        
        % clean and fill (correct isolated black and white pixels)
        img_rl_clean = bwmorph(v_repeated_line_bin,'clean');
        img_rl_fill = bwmorph(img_rl_clean,'fill');
        
        % show after correction
        subplot(4,2,3);
        imshow(img_rl_fill);
        title('clean');
        
        % % make average eliminating loose pixels
        % img_rl_majority = bwmorph(img_rl_open,'majority');
        %
        % % show result after majority/averaging
        % subplot(5,2,5);
        % imshow(img_rl_majority);
        % title('majority');
        
        % skeletonize first time
        img_rl_skel = bwmorph(img_rl_fill,'skel',inf);
        
        % show skeletonized
        subplot(4,2,4);
        imshow(img_rl_skel);
        title('skeleton');
        
        % open filter image
        img_rl_open = bwareaopen(img_rl_skel, 5);  % remove unconnected pixels with length X
        
        % show result after open filter
        subplot(4,2,5);
        imshow(img_rl_open);
        title('open');
        
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
        
        % % display dead ends
        % subplot(5,2,7);
        % imshow(Dmask);
        % title('dead ends');
        
        % display leftover veins
        subplot(4,2,6);
        imshow(skelD);
        hold all;
        title('new skeleton');
        
        skelD = filledgegaps(skelD, 7);
        
        % clean and fill (correct isolated black and white pixels)
        img_rl_clean = bwmorph(skelD,'clean');
        img_rl_result = bwmorph(img_rl_clean,'fill');
        
        % skeletonize again to optimize branchpoint detection
        img_rl_result = bwmorph(img_rl_result,'skel',inf);
        
        % find branchpoints remaining and put in array
        bw1br = bwmorph(img_rl_result, 'branchpoints');
        [i,j] = find(bw1br);
        branch_array = [j,i];
        
        % display result without branchpoints
        subplot(4,2,7);
        imshow(img_rl_result);
        title('new skeleton');
        
        % save to file DEBUG
        %imwrite(img_rl_result,'test2.png')
        
        % display result with branchpoints
        subplot(4,2,8);
        imshow(img_rl_result);
        hold all;
        plot(branch_array(:,1),branch_array(:,2),'o','color','cyan','linewidth',2);
        title('new skeleton with branchpoints');
        
        % result in separate figure
        figure;
        subplot(2,1,1);
        imshow(img);
        title('original');
        
        subplot(2,1,2);
        imshow(img_rl_result);
        hold all;
        plot(branch_array(:,1),branch_array(:,2),'o','color','cyan','linewidth',2);
        title('veins and branchpoints');
        
        
        %% ================= end method specific ==============================
        % save result to matches array
        matches_array(compare, compare_with) = 6;
    end
end

save('result_matches.mat','matches_array');


