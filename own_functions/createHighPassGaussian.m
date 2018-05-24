function G = createHighPassGaussian(a, b, size)
% size must be odd.
    if mod(size,2)
        size = size+1;
    end
    x = -size:size;
    y = transpose(-size:size);
    x0 = round(size/2);
    y0 = round(size/2);
    
    D = ( ( x - x0 ).^2 + ( y - y0 ).^2 ).^(1/2);
    D0 = ( x0^2 + y0^2 )^(1/2);
    G = ( a * (1 - exp( -D.^2 / (2 * D0^2) )) + b);

end