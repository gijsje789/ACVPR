function [imageSet] = read_imageSet(dataStart, dataStop)
% Reads specific imageset from parent directory

% Parameters:
%  dataStart    - Start folder -- string containing 4 chars
%  dataStop     - Stop folder  -- string containing 4 chars

% Returns:
%  imageSet     - Cell array containing: image, person, finger, photonumber
%                 respectively

% Usage: 
%  Take all data of a single person:
%   person2 = imageSet(cell2mat(imageSet(:,2)) == 2,:,:,:) 
%  Take all pointer fingers:
%   finger1 = imageSet(cell2mat(imageSet(:,3)) == 2,:,:,:)

for k=1:4
    if dataStop(k) ~= '0'
        str = k;
        break
    end
end
output1 = dataStop(str:4); 

for k=1:4
    if dataStart(k) ~= '0'
        str = k;
        break
    end
end
output2 = dataStart(str:4); 
imgtot = 0;
for k = str2num(output2) : str2num(output1)
    fldr = pad(num2str(k),4,'left','0');
    for finger = 1:6
        for photonr = 1:4
            imgtot = imgtot+1;
            formatSpec = 'dataset_mc/%s/%s_%s_%s_*.png';
            str = sprintf(formatSpec,fldr,fldr,num2str(finger),num2str(photonr));
            folderinfo = dir(str);
            file = folderinfo.name;
            img = imread(file);
            imageSet(imgtot, :) = {img, str2num(fldr), finger, photonr};
        end
    end
end

