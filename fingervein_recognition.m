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

blobAnalyzer = vision.BlobAnalysis('LabelMatrixOutputPort', true, ...
                                    'MinimumBlobArea', 25);
%% Variables

%% Processing
% Show an image
origIm = figure;
subplot(1,2,1)
imshow(images{1}, [])

bw_thres = graythresh(images{1});
bw_im = imbinarize(images{1}, bw_thres);
subplot(1,2,2)
imshow(bw_im);

[area, centroid, ~, label] = blobAnalyzer(bw_im);
[~, I] = max(area);
hold on;
plot(centroid(I,1), centroid(I,2), 'r*')
hold off;