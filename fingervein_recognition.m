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
GaborSigma = 5;
dF = 2.5;
F = 0.1014;%(sqrt( log(2/pi))*(2^dF + 1)/(2^dF - 1)) / GaborSigma;
% should be optimal F according to Zhang and Yang.

%% Processing
% Show an image

images{1} = cropFingerVeinImage(images{1});

origIm = figure;
imshow(images{1}, []);

%% gaussian filter

S= im2double(images{1});

sigma = 4;
L = 2*ceil(sigma*3)+1;
h = fspecial('gaussian', L, sigma);% create the PSF
imfiltered = imfilter(S, h, 'replicate', 'conv'); % apply the filter

S = imfiltered;%mat2gray(imfiltered, [0 256]);

figure;
imshow(S, []);

% %% maximum curvature method
% sigma = 5; % Parameter
% v_max_curvature = max_curvature(double(images{1}),1,sigma);
% 
% % Binarise the vein image
% md = median(v_max_curvature(v_max_curvature>0));
% v_max_curvature_bin = v_max_curvature > md; 
% 
% figure;
% subplot(2,1,1);
% imshow(v_max_curvature,[]);
% subplot(2,1,2);
% imshow(v_max_curvature_bin);
% 
% %% repeated lines method
% 
% fvr = ones(size(images{1}));
% 
% veins = repeated_line(S, fvr, 3000, 1, 17);
% 
% % Binarise the vein image
% md = median(veins(veins>0));
% v_repeated_line_bin = veins > md;
% 
% se = strel('disk',1,0);
% v_repeated_line_bin = imerode(v_repeated_line_bin,se);
% 
% figure; 
% subplot(2,1,1);
% imshow(veins,[]);
% subplot(2,1,2);
% imshow(v_repeated_line_bin);

%% Mean curvature method

v_mean_curvature=mean_curvature(S);

% Binarise the vein image
md = 0.03;
v_mean_curvature_bin = v_mean_curvature > md; 

figure;
subplot(2,1,1);
imshow(v_mean_curvature);
subplot(2,1,2);
imshow(v_mean_curvature_bin);
