clc; clear; close all;

% load database
load 'database.mat';
[data_count, ~] = size(data);

array = [];

for i = 1:8
    for j = 1:8
        
        reference_im = data{i,12};
        compare_im = data{j,12};
        
        reference_im_bin = data{i,6};
        compare_im_bin = data{j,6};
        
        error = lbp_matching(reference_im, compare_im, reference_im_bin, compare_im_bin);
        
        fprintf('%d %d\n',i,j);
        array(i,j) = error;
        
    end
end

min = min(min(array));
max = max(max(array));

full_match_percentage = 100-(array./(max-min).*100);


