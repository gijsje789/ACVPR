function [indexed, error, non_matched_points, matchPercentage] = matchLBPfeatures(features1, features2)
% requires LBP featuress of size N x 255.
% requires LBP(255) to be 0.
if size(features1,1) < size(features2,1)
    indexed = zeros(size(features1,1),1);
    error = 0;
    non_matched_points(1,1) = 0;
    for i = 1:size(features1,1)
        smallest = inf; % ensure it is always the largest one
        for j = 1:size(features2,1)
            if isempty(indexed(indexed==j)) % as long as the point being matched is not already matched to another point.
                temp = abs(features1(i,:) - features2(j,:)); % have the smallest possible error, not caring which LBP differs.
                if sum(temp) < sum(smallest)
                    smallest = temp;
                    smallest_j = j;
                else
                end
            end
        end
        error = error + sum(smallest);
        indexed(i,1) = smallest_j;
    end
    temp = 1;
    for it = 1:size(features2,1)
       if isempty(indexed(indexed==j))
          non_matched_points(temp,1) = it; 
          temp = temp + 1;
       end
    end
elseif size(features2,1) <= size(features1,1)
    indexed = zeros(size(features2,1),1);
    error = 0;
    non_matched_points(1,1) = 0;
    for i = 1:size(features2,1)
        smallest = inf;
        for j = 1:size(features1,1)
            if isempty(indexed(indexed==j))
                temp = abs(features2(i,:) - features1(j,:));
                if sum(temp) < sum(smallest)
                    smallest = temp;
                    smallest_j = j;
                else
                end
            end
        end
        error = error + sum(smallest);
        indexed(i,1) = smallest_j;
    end
    temp = 1;
    for it = 1:size(features1,1)
       if isempty(indexed(indexed==j))
          non_matched_points(temp,1) = it; 
          temp = temp + 1;
       end
    end
end
matchPercentage = (-100/15000) * error + 100;
end