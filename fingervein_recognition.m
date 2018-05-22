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
subplot(1,3,1)
imshow(images{1}, [])

bw_thres = graythresh(images{1});
bw_im = imbinarize(images{1}, bw_thres);
[area, centroid, ~, label] = blobAnalyzer(bw_im);
[~, I] = max(area);

subplot(1,3,2)
imshow(bw_im);
hold on;
plot(centroid(I,1), centroid(I,2), 'r*')
hold off;

cropped = images{1}(centroid(I,2)-80:centroid(I,2)+80, 1:end);
subplot(1,3,3)
imshow(cropped, []);