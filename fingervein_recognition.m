%% Initialise
% Clear variables, close figures
clear variables
close all

% Read image folder
imageFolder = dir('dataset/data/0001/*.png');
nfiles = length(imageFolder);    % Number of files found
for ii=1:nfiles
   currentfilename = imageFolder(ii).name;
   currentimage = imread(currentfilename);
   images{ii} = currentimage;
end
%% Variables
% i = 1; % Which finger to take.
GaborSigma = 5; % Both [1] and [2]
dF = 1.12;  % [2] -> 0.5-2.5
F = (sqrt(log(2)/pi) * ((2^dF + 1)/(2^dF - 1)))/GaborSigma; %[1]
% F = ((1/pi) * sqrt( log(2)/2 ) * ((2^dF + 1)/(2^dF - 1)))/GaborSigma; [2]
   

%% Processing
% Show an image
origIm = figure;
for it=1:24
    figure(origIm)
    subplot(3,3,1)
    imshow(images{it}, [])
    title('Original image');

    cropped = cropFingerVeinImage(images{it});
    G = createGaborFilter(GaborSigma, F, 20);
    
    subplot(3,3,4)
    imshow(cropped, []);
    title('Cropped image');
    subplot(3,3,7)
    histogram((cropped), 256);
    title('Histogram cropped image');
    
    enhanced = conv2(cropped, G);
    subplot(3,3,3)
    imshow((real(enhanced)), []);
    title('real of cropped * Gabor');
    subplot(3,3,2)
    histogram((real(enhanced)));
    title('real of cropped * Gabor');
    
    subplot(3,3,6)
    imshow((imag(enhanced)), []);
    title('imag of cropped * Gabor');
    subplot(3,3,5)
    histogram((imag(enhanced)));
    title('imag of cropped * Gabor');
    
    subplot(3,3,9)
    imshow((abs(enhanced)), []);
    title('Abs of cropped * Gabor');
    subplot(3,3,8)
    histogram((abs(enhanced)));
    title('Abs of cropped * Gabor');
end

% [1]:
% Yang, J., Shi, Y., Yang, J., & Jiang, L. (2009, November). A novel
% finger-vein recognition method with feature combination. In Image
% Processing (ICIP), 2009 16th IEEE International Conference on (pp.
% 2709-2712). IEEE.

%[2]:
% Zhang, J., & Yang, J. (2009, December). Finger-vein image enhancement
% based on combination of gray-level grouping and circular gabor filter. In
% Information Engineering and Computer Science, 2009. ICIECS 2009.
% International Conference on (pp. 1-4). IEEE.
