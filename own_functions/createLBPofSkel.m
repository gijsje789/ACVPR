function histPerPoint = createLBPofSkel(skel, branch_array)
window_size = 3;
    for it = 1:size(branch_array,1)
       if branch_array(it,1)-window_size > 0 && branch_array(it,2)-window_size > 0 ...
               && branch_array(it,1)+window_size <= size(skel,2) ...
               && branch_array(it,2)+window_size <= size(skel,1)
           % extract the lbp information as if it was an image. Each point
           % is an rotation variant lbp pattern.
           lbp_img = LBP(skel(branch_array(it,2)-window_size:branch_array(it,2)+window_size,...
                     branch_array(it,1)-window_size:branch_array(it,1)+window_size),1); 
           for rows = 1:size(lbp_img,1)
               for cols = 1:size(lbp_img,2)
                   temp = 500;
                   for j=0:7
                       shifted = circshift(de2bi(lbp_img(rows,cols)),j);
                       shifted = bi2de(shifted);
                        if shifted < temp
                            temp = shifted;
                        end
                   end
                   lbp_img2(rows,cols) = temp;
               end
           end
           histPerPoint(it,:) = histogramCreator(lbp_img2);
       else
           histPerPoint(it,:) = zeros(1,256);
       end
    end
end