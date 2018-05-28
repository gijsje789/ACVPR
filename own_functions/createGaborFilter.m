function G = createGaborFilter(sigma, F, size)
    persistent gabor;
    curfig = gcf;
    
    if ishandle(findobj('type', 'figure', 'name', 'gabor'))
    else
        gabor = figure('name', 'gabor');
    end
    
    x = -size:size;
    y = transpose(-size:size); 

    K = 1 / (2*pi*sigma^2);
    g = K .* exp( -((x.^2 + y.^2)/(2*sigma^2)) ); % Nice looking Gaussian with low peak and wide distribution.
    G = g .* exp( 2*pi*1i*F*( sqrt( x.^2 + y.^2 ) ) ); % Only the exponent looks as expected. USing the rest looks more like the traditional gabor.

    figure(gabor)
    subplot(1,3,1)
    surf(x,y,real(G));
    title('Real part of Gabor filter');
    subplot(1,3,2)
    surf(x,y,imag(G));
    title('Imaginary part of Gabor filter');
    subplot(1,3,3)
    surf(x,y,abs(G));
    title('Absolute part of gabor filter');
    
    figure(curfig)
end