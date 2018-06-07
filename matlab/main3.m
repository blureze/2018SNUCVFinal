% Similar to main2.m, we first use SCW to get license_localization. What is
% different is that when detecting logo localization, we crop the region
% contains logo and license plate as the final output. We assume that the
% logo is above the region of logo within the same region of the width of
% license plate

%% initialize
sobel_threshold = 0.2;
canny_threshold = 0.6;
%% single file
% load image
sceneImage = im2double(imread('../car/hyundai/HPIM1236.jpg'));
sceneImage = rgb2gray(sceneImage);
sceneImage_scale = imresize(sceneImage, [960,1280]);
% figure, imshow(sceneImage);

% get the coordinate of vehical license
[license_image_set, x, y, w, h] = license_detection(sceneImage_scale, sobel_threshold, canny_threshold, 1);

% get the region includes logo and license plate
new_y = y - (w-h);
new_h = w;

if new_y < 1
    new_y = 1;
end

if new_h > size(sceneImage_scale,1)
    new_h = size(sceneImage_scale,1);
end

logo_region = sceneImage_scale(new_y:new_y+new_h-1, x:x+w-1);
figure, imshow(logo_region);
title('Logo Region');
%%
% rescale license plate to fixed size
crop_image = imresize(logo_region, [NaN, 150]);

output_dir_name = '../car/hyundai/logo/';
image_name = 'IMG_0448';

% save the image
filename = sprintf('%s%s.jpg', output_dir_name, image_name);
imwrite(crop_image, filename);
fprintf('Save image %s\n', filename);
    
% for i = 1: numel(license_image_set)
%     license_image = cell2mat(license_image_set(i));
%     figure, imshow(license_image);
%     title('License Plate');
% 
% 
% 
% 
% end



%% all files in directory
input_dir_name = '../car/hyundai/';
output_dir_name = '../car/hyundai/license/';
MyFolderInfo = dir(input_dir_name);

for i = 4: numel(MyFolderInfo)-2 % the first 3 components are '.', '..', '.DS_Store'
    
    img_dir = sprintf('%s%s', input_dir_name,MyFolderInfo(i).name);

    sceneImage = im2double(imread(img_dir));
    sceneImage = rgb2gray(sceneImage);
    sceneImage_scale = imresize(sceneImage, [960,1280]);

    % get the roi region of vehical logo
    [license_image, x, y, w, h] = license_detection(sceneImage_scale, sobel_threshold, canny_threshold, 1);
    
%     % get the region includes the vehicle logo and head light
%     crop_image = vehicle_segment(sceneImage, x, y, w, h);
% 
%     % detect logo location with phase congruency
%     logo_region = phase_congruency(crop_image);

    % save the image
    if ~isempty(license_image)
        filename = sprintf('%s%s', output_dir_name, MyFolderInfo(i).name);
        imwrite(license_image, filename);
        fprintf('%d: Save image %s\n', i, filename);
    else
        filename = sprintf('%s%s', output_dir_name, MyFolderInfo(i).name);
        imwrite(sceneImage, filename);
        fprintf('%d: Save image %s\n', i, filename);        
    end

end

fprintf('finished!');