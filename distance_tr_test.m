function full_match_percentage = distance_tr_test(skel_1, skel_2)

%clc; clear; close all;

%skel_1 = imread('test1.png');
%skel_2 = imread('test2.png');

% figure;
% imshow(skel_1,[]);
% title('original');

dist_img2 = bwdist(skel_2,'chessboard');

max_distance = max(dist_img2(:));

% get row and col count
[rows, cols] = size(skel_1);

total_pixels_found = 0;
points = 0;

% for skeleton image 1, check value for distance image 2
for row=1:rows
    for col=1:cols
        if skel_1(row, col) == 1
            points = points + dist_img2(row, col);
            total_pixels_found = total_pixels_found + 1;
        end
        
    end
end

% get mean distance
mean_distance = points/total_pixels_found;

full_match_percentage = 100 - (mean_distance/max_distance*100);

% skel_1 = 60*skel_1;
% comb = skel_1 + dist_img2;
% 
% figure;
% imshow(comb, []);
% title('both');




