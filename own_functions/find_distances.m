function distances = find_distances(branch_array)

rows_arr = numel(branch_array(:,1));

distances = ones(rows_arr);

for i = 1:rows_arr
   for j = 1:rows_arr
      if i == j
          distances(i,j) = 0;
%       elseif i > j
%           distances(i,j) = 0;
      else
          distances(i,j) = sqrt((branch_array(j,1)-branch_array(i,1)).^2+((branch_array(j,2)-branch_array(i,2)).^2));
      end
   end
end