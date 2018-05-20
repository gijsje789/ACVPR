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

%% Processing
% Show an image
origIm = figure;
subplot(1,2,1)
imshow(images{1}, [])
