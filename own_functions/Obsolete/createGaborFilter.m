function G = createGaborFilter(sigma, F, size)
    x = -size:size;
    y = transpose(-size:size); 

    K = 1 / (2*pi*sigma^2);
    g = K .* exp( -(x.^2 + y.^2)/(2*sigma^2) ); % Nice looking Gaussian with low peak and wide distribution.
    G = g .* exp( 2*pi*i*F*( sqrt( x.^2 + y.^2 ) ) ); % Only the exponent looks as expected. USing the rest looks more like the traditional gabor.

end