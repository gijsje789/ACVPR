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
dF = 8;
Gaborf0 = 0.25;%(sqrt( log(2/pi))*(2^dF + 1)/(2^dF - 1)) / GaborSigma;
GaborK = 1/(2 * pi * GaborSigma^2);

%% Processing
% Show an image
origIm = figure;
subplot(2,1,1)
imshow(images{1}, [])

% % Binarize using a adaptive threshold
% Thres = adaptthresh(images{1}, 0.6);
% bin = imbinarize(images{1}, Thres);
% 
% subplot(1,2,2)
% imshow(bin);
x=-25:25;
y=-25:25;
g = GaborK * exp((-(x.^2 + transpose(y.^2))) / (2 * GaborSigma^2));
Gabor = g * exp(2*pi * i * Gaborf0 * sqrt(x.^2 + transpose(y.^2)));
subplot(2,1,2)
surf(x,y,abs(Gabor));