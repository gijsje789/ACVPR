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
y=transpose(-25:25);
subplot(2,1,2)

K = 1 / (2*pi*GaborSigma^2);
g = K * exp( -(x.^2 + y.^2)/(2*GaborSigma^2) ); % Nice looking Gaussian with low peak and wide distribution.
G = g * exp( 2*pi*1i*F*( sqrt( x.^2 + y.^2 ) ) ); % Only the exponent looks as expected. USing the rest looks more like the traditional gabor.

figure
subplot(1,3,1)
surf(x,y,real(G));
subplot(1,3,2)
surf(x,y,imag(G));
subplot(1,3,3)
surf(x,y,abs(G));

outIm = conv2(images{1}, abs(G), 'same');
figure;
imshow(abs(outIm), []);