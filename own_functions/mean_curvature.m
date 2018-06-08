function H = mean_curvature(im)

  Ix = Dx(im); 
  Iy = Dy(im);
  Ixx = Dx(Ix);
  Iyy = Dy(Iy);    
  Ixy = Dx(Iy);
  H = 0.5.*((Ixx.*(Iy.^2) - 2 .*Ixy.*Ix.*Iy+Iyy.*(Ix.^2))./((Ix.^2 + Iy.^2).^(3/2)));

end

function d = Dx(u)

  [row,column,p] = size(u);
  d = zeros(row,column,p); 
  d(:,2:column,:) = u(:,1:column-1,:) - u(:,2:column,:);
  d(:,1,:) = u(:,1,:) - u(:,column,:);

end

function d = Dy(u)

  [row, column, p] = size(u);
  d = zeros(row, column, p);
  d(2:row,:,:) = u(1:row-1,:,:) - u(2:row,:,:);
  d(1,:,:) = u(1,:,:)-u(row,:,:);

end