function hist = histogramCreator(img)
    hist = zeros(1,256);
    for row = 1:size(img,1)
        for col = 1:size(img,2)
            hist(img(row,col)+1) = hist(img(row,col)+1)+1;
        end
    end
    hist(:,255) = 0;
end