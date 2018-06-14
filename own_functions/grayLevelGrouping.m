function transform = grayLevelGrouping(cropped)
% Gray level grouping based on the paper of: 
% Chen, Z., Abidi, B. R., Page, D. L., & Abidi, M. A. (2006). Gray-level 
% grouping (GLG): an automatic method for optimized image contrast 
% Enhancement-part I: the basic method. IEEE transactions on image 
% processing, 15(8), 2290-2302.

% Extract the histogram of the original image.
    H = imhist(cropped);
% Count all the zeroes that are in the histogram.
    idx=H==0;
    n=sum(idx(:));
% Shift the first n-nonzero histogram components into gray-level groups.
% Based on equation (1) and (2).
    k = 1;
    max_k = size(H,1);
    G_bins=[];
    L_bins=[];
    R_bins=[];
    for i = 1:n
        not_done = true;
        while(not_done)
            if(H(k) ~= 0)
               G_bins(n,i)=H(k);
               L_bins(n,i)=k;
               R_bins(n,i)=k;
               k=k+1;
               not_done=false;
            else
               k=k+1;
            end
        end
    end
 
% Find the first occuring smallest gray-level group, based on equation (3).
    [a,ia] = min(G_bins(n,:));
% Grouping of the gray-level groups, based on equations (4) untill (6).
    if ia == 1
        i_acc = ia;
    elseif G_bins(n,ia-1) <= G_bins(n,ia+1)
        i_acc = ia-1;
    else
        i_acc = ia;
    end
    
    if ia > 1 && ia < max_k
        b = min([G_bins(n,ia-1) G_bins(n,ia+1)]);
    elseif ia == 1
        b = G_bins(n,ia+1);
    elseif ia == max_k
        b = G_bins(n,ia-1);
    end
    
    for i=1:n-1
        if i>=1 && i<=i_acc-1
            G_bins(n-1, i) = G_bins(n,i);
        elseif i==i_acc
            G_bins(n-1,i) = a+b;
        elseif i>=i_acc
            G_bins(n-1,i) = G_bins(n,i+1);
        end
    end

% Left and right limits adjustment, based on equations (7), (8)
    for i=1:n-1
        if i>=1 && i<=i_acc
            L_bins(n-1, i) = L_bins(n,i);
        elseif i>=i_acc
            L_bins(n-1,i) = L_bins(n,i+1);
        end
        
        if i>=1 && i<=i_acc-1
            R_bins(n-1, i) = R_bins(n,i);
        elseif i>=i_acc
            R_bins(n-1,i) = R_bins(n,i+1);
        end
    end
    
% Mapping and ungrouping, based on equation (9) and (10)
    alpha = 0.8; % based on their treatments.
    N(n-1)= (max_k-1)/(n-1-alpha);
% Defineing the transformation matrix, based on equation (11) untill (15).
    for k=1:max_k
        for i=1:n-1
            if k == G_bins(n-1,i) && L_bins(n-1,i)~=R_bins(n-1,i)
                if L_bins(n-1,1) == R_bins(n-1,1)
                    T(n-1,k) = (i-alpha-( (R_bins(n-1,i)-k)/(R_bins(n-1,i)-L_bins(n-1,i)) ))*N(n-1)+1;
                else
                    T(n-1,k) = (i-( (R_bins(n-1,i)-k)/(R_bins(n-1,i)-L_bins(n-1,i)) ))*N(n-1)+1;
                end
                
            elseif k == G_bins(n-1,i) && L_bins(n-1,i)==R_bins(n-1,i)
                if L_bins(n-1,1) == R_bins(n-1,1)
                    T(n-1,k) = (i-alpha)*N(n-1);
                else
                    T(n-1,k) = i*N(n-1);
                end
                
            elseif k>G_bins(n-1,i) && k<G_bins(n-1,i+1)
                if L_bins(n-1,1) == R_bins(n-1,1)
                    T(n-1,k) = (i-alpha)*N(n-1);
                else
                    T(n-1,k) = i*N(n-1);
                end
                
            elseif k<=L_bins(n-1,1)
                T(n-1,k)=0;
                
            elseif k>=R_bins(n-1,n-1)
                T(n-1,k)=max_k;
            end
        end
    end
    transform = T(n-1,:);
end