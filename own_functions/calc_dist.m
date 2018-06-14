clear; clc; close all;

%% find the distances

aFileData = load('branch_array1.mat');
% names of the variables stored:
variableNames = fieldnames(aFileData);
% use the first name and "dynamic field names", i.e., (...):
branch_arr1 = aFileData.(variableNames{1});

aFileData = load('branch_array1.mat');
% names of the variables stored:
variableNames = fieldnames(aFileData);
% use the first name and "dynamic field names", i.e., (...):
branch_arr2 = aFileData.(variableNames{1});

tic;

distances1 = find_distances(branch_arr1);
distances2 = find_distances(branch_arr2);

error = 0;

% find biggest matrix
if (numel(distances1(:,1)) < numel(distances2(:,1)))
    temp = distances1;
    distances1 = distances2;
    distances2 = temp;
    
    temp2 = branch_arr1;
    branch_arr1 = branch_arr2;
    branch_arr2 = temp2;
end

rows = numel(distances1(:,1));
cols = numel(distances1(1,:));
match  = cell(numel(distances1(:,1)), 3);        % Pre-allocate
matches = 0;
errors = 0;
total=0;
totalFind = 0;
matchFound = 0;

for row = 1:rows
    for col = 1:cols
        if(distances1(row,col)~=0)
            [foundX, foundY] = find(distances2 == distances1(row,col));
            
            for index = 1:numel(foundX)
                if((branch_arr1(row,1)==branch_arr2(foundX(index),1) && ...
                    branch_arr1(row,2)==branch_arr2(foundX(index),2)) && ...
                    (branch_arr1(col,1)==branch_arr2(foundY(index),1) && ...
                    branch_arr1(col,2)==branch_arr2(foundY(index),2)))
                        matches = matches + 1;
                end
            end
        end
    end
end

toc;

percentage = (matches+numel(distances1(:,1)))/(numel(distances1))*100;

% if( ((((branch_arr1(row,1)-error)<=branch_arr2(foundX(index),1)) || ((branch_arr1(row,1)+error)>=branch_arr2(foundX(index),1))) && ...
%                     (((branch_arr1(row,2)-error)<=branch_arr2(foundX(index),2)) || ((branch_arr1(row,2)+error)>=branch_arr2(foundX(index),2)))) && ...
%                     ((((branch_arr1(col,1)-error)<=branch_arr2(foundY(index),1)) || ((branch_arr1(col,1)+error)>=branch_arr2(foundY(index),1))) && ...
%                     (((branch_arr1(col,2)-error)<=branch_arr2(foundY(index),2)) || ((branch_arr1(col,2)+error)>=branch_arr2(foundY(index),2)))))
%                         matches = matches + 1;