function G = createHighPassGaussian(a, b, size)
% Based on: 
% Lee, E. C., Jung, H., & Kim, D. (2011). New finger biometric method using
% near infrared imaging. Sensors, 11(3), 2319-2333.
%
    x = 1:size;
    y = transpose(1:size);
    x0 = round(size/2);
    y0 = round(size/2);
    
    D = ( ( x - x0 ).^2 + ( y - y0 ).^2 ).^(1/2);
    D0 = ( x0^2 + y0^2 )^(1/2);
    G = a * (1 - exp( -((D.^2) / (2 * (D0^2))) )) + b;

end