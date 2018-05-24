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
GaborSigma = 5;
dF = 1.12; 
F = (sqrt(log(2)/pi) * ((2^dF + 1)/(2^dF - 1)))/GaborSigma;
% F = ((sqrt(2*log(2))/(2*pi)) * ((2^dF + 1)/(2^dF - 1)))/GaborSigma;
% F = ((1/pi) * sqrt( log(2)/2 ) * ((2^dF + 1)/(2^dF - 1)))/GaborSigma;
   

%% Processing
% Show an image
origIm = figure;
gabor = figure;

for i=1:24
    figure(origIm)
    subplot(1,3,1)
    imshow(images{i}, [])

    cropped = cropFingerVeinImage(images{i});
    G = createGaborFilter(GaborSigma, F, 20);
    subplot(1,3,2)
    imshow(cropped, []);
    
    enhanced = conv2(cropped, abs(G));
    subplot(1,3,3)
    imshow(enhanced, []);
end