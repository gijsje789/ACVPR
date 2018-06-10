function im = get_fingerImage(imageSet, person, finger, number)
% Returns a specific image using data indices person,finger,number from a
% dataset

% Parameters:
%  person   - person number -- integer
%  finger   - finger number -- integer
%  number   - photo  number -- integer

% Returns:
%  im       - image of the person, their finger, the corresponding photo

imageSet = imageSet(cell2mat(imageSet(:,2)) == person,:,:,:);
imageSet = imageSet(cell2mat(imageSet(:,3)) == finger,:,:,:);
imageSet = imageSet(cell2mat(imageSet(:,4)) == number,:,:,:);

im = cell2mat(imageSet(1,1));


