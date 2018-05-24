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
% F = ((sqrt(2*log(2))/(2*pi)) * ((2^dF + 1)/(2^dF - 1)))/GaborSigma;
F = ((1/pi) * sqrt( log(2)/2 ) * ((2^dF + 1)/(2^dF - 1)))/GaborSigma;
x = -20:20;
y = transpose(-20:20);    

%% Processing
% Show an image
origIm = figure;
gabor = figure;

K = 1 / (2*pi*GaborSigma^2);
g = K * exp( -(x.^2 + y.^2)/(2*GaborSigma^2) ); % Nice looking Gaussian with low peak and wide distribution.
G = g .* exp( 2*pi*i*F*( sqrt( x.^2 + y.^2 ) ) ); % Only the exponent looks as expected. USing the rest looks more like the traditional gabor.

subplot(2,3,1)
surf(x,y,real(G));
subplot(2,3,2)
surf(x,y,imag(G));
subplot(2,3,3)
surf(x,y,abs(G));
subplot(2,3,4)
imshow(real(G), []);
subplot(2,3,5)
imshow(imag(G),[]);
subplot(2,3,6)
imshow(abs(G),[]);

for i=1:24
    figure(origIm)
    subplot(1,3,1)
    imshow(images{i}, [])

    cropped = cropFingerVeinImage(images{i});
    
    lut = uint8(grayLevelGrouping(cropped));
    
    transformed = intlut(cropped, lut);
    
    subplot(1,3,2)
    imshow(transformed, []);
    
    enhanced = conv2(cropped, abs(G));
    subplot(1,3,3)
    imshow(enhanced, []);
end