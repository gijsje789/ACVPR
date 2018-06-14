clc; clear; close all;

brickWall = imread('bricks.jpg');
rotatedBrickWall = imread('bricksRotated.jpg');
carpet = imread('carpet.jpg');

lbpBricks1 = extractLBPFeatures(brickWall,'Upright',false,'radius',1);
lbpBricks2 = extractLBPFeatures(rotatedBrickWall,'Upright',false,'radius',1);
lbpCarpet = extractLBPFeatures(carpet,'Upright',false,'radius',1);

brickVsBrick = (lbpBricks1 - lbpBricks2).^2;
brickVsCarpet = (lbpBricks1 - lbpCarpet).^2;

bvb = sum(brickVsBrick);
bvc = sum(brickVsCarpet);

x = abs(bvc-bvb);

figure;
bar([brickVsBrick; brickVsCarpet]','grouped')
title('Squared Error of LBP Histograms')
xlabel('LBP Histogram Bins')
legend('Bricks vs Rotated Bricks','Bricks vs Carpet')