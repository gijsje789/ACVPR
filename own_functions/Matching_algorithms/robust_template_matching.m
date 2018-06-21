function full_match_percentage = robust_template_matching(img_reference, img)
% Template matching for RL/MAC/MEC binary/sekeltonized images

% Parameters:
%  img_skeleton_reference     -    reference image, RL/MAC/MEC binary/skeletonized
%  img_skeleton               -    compare image, RL/MAC/MEC binary/skeletonized

% Returns:
%  full_match_percentage  -    output match percentage

% add images to see effect of transformation
%comb_after = Ir + img;\

c_w = 8;
c_h = 7;
sigma = 0;
    
for s = 1:(2*c_h)
    for t = 1:(2*c_h)
        for y = 1:(numel(img(:,1))-2*c_h)
            for x = 1:(numel(img(1,:))-2*c_w-1)
                sigma = sigma + calc_sig(img(t+y,s+x),img_reference(c_h+y,c_w+x));
            end
        end
        N_m(s,t) = sigma;
        sigma = 0;
    end
end

[s0, t0] = find(N_m == min(N_m(:)));

s0 = s0(1);
t0 = t0(1);

sum_i = 0;

for j = 1+t0:(t0+numel(img(:,1))-2*c_h)
    for i = 1+s0:(s0+numel(img(1,:))-2*c_w)
        sum_i = sum_i + calc_sig(img(j,i),0);
    end
end

sum_r = 0;

for j = c_h:(numel(img(:,1))-c_h-1)
    for i = c_w:(numel(img(1,:))-c_w-1)
        sum_r = sum_r + calc_sig(0,img_reference(j,i));
    end
end
    

    full_match_percentage = min(N_m(:))/(sum_i+sum_r);

    % calculate perfect match
    %full_match_percentage = 100*sum(comb_after(:) == 2)/(sum(comb_after(:) == 1) + sum(comb_after(:) == 2));
end


function sigma = calc_sig(p1, p2)

if abs(p1-p2) == 1   %max value
    sigma = 1;
else
    sigma = 0;
end

end
