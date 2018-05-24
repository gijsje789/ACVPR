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
dF = 1.12;  % [2]
F = (sqrt(log(2)/pi) * ((2^dF + 1)/(2^dF - 1)))/GaborSigma; %[1]
% F = ((1/pi) * sqrt( log(2)/2 ) * ((2^dF + 1)/(2^dF - 1)))/GaborSigma; [2]
   
a = 50;
b = -4;
%% Processing
% Show an image
origIm = figure;
gabor = figure;

for i=1:24
    figure(origIm)
    subplot(1,4,1)
    imshow(images{i}, [])

    cropped = cropFingerVeinImage(images{i});
%     G = createGaborFilter(GaborSigma, F, 20);
    G = createHighPassGaussian(a,b,5);
    
    subplot(1,4,2)
    surf(1:5, 1:5, G)
    subplot(1,4,3)
    imshow(cropped, []);    
    enhanced = conv2(cropped, G);
    subplot(1,4,4)
    imshow(enhanced, []);
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
