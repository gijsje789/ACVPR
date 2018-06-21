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

%% Processing
% Show an image
origIm = figure;

for i=1:24
    subplot(1,2,1)
    imshow(images{i}, [])

    cropped = cropFingerVeinImage(images{i});

    subplot(1,2,2)
    imshow(cropped, []);
end

%% mean curvature
veins = mean_curvature(currentimage, 1, 5);

figure, imshow(veins);