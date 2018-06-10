function skelD = removeDeadEnds(img, px)
% removes dead ends < px pixels in length

% Parameters:
%  img     -    skeletonized image to remove dead ends
%  px      -    pixels length of dead ends to remove

% Returns:
%  skelD               -   skeletonized image, dead ends removed

% find branchpoints & endpoints
B = bwmorph(img, 'branchpoints');
E = bwmorph(img, 'endpoints');

[y,x] = find(E);
B_loc = find(B);

Dmask = false(size(img));

% find dead ends
for i = 1:numel(x)
    D = bwdistgeodesic(img,x(i),y(i));
    distanceToBranchPt = min(D(B_loc));
    if distanceToBranchPt < px
        Dmask(D < distanceToBranchPt) = true;
    end
end

% subtract dead ends
skelD = img - Dmask;