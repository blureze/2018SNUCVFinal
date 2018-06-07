%% initialize
sobel_threshold = 0.2;
canny_threshold = 0.6;
%% single file
% load image
sceneImage = im2double(imread('../car/nissan/HPIM1250.jpg'));
sceneImage = rgb2gray(sceneImage);
sceneImage_scale = imresize(sceneImage, [960,1280]);

% get the coordinate of vehical license
[license_image, x, y, w, h] = license_detection(sceneImage_scale, sobel_threshold, canny_threshold, 1);
figure, imshow(license_image);

% get the region includes the vehicle logo and head light
crop_image = vehicle_segment(sceneImage_scale, x, y, w, h);

% draw the region
% figure, imshow(sceneImage);
% hold on;
% crop_image = sceneImage(new_y:new_y+new_h-1, new_x:new_x+new_w-1);
% rectangle('Position', [new_x,new_y,new_w,new_h], 'EdgeColor','r');
% figure, imshow(crop_image);

% detect logo location with phase congruency
[logo_region, min_x, max_x] = phase_congruency(crop_image);
figure, imshow(logo_region);

% restrict logo's y-value and make it as a square


%% all files in directory
% input_dir_name = '../day_gray_scale/';
% output_dir_name = '../crop-image(gray)/';
% MyFolderInfo = dir(input_dir_name);
% 
% for i = 4: numel(MyFolderInfo) % the first 3 components are '.', '..', '.DS_Store'
%     
%     img_dir = sprintf('%s%s', input_dir_name,MyFolderInfo(i).name);
% 
%     sceneImage = im2double(imread(img_dir));
% %     sceneImage = rgb2gray(sceneImage);
% 
%     % get the roi region of vehical logo
%     [license_image, x, y, w, h] = license_detection(sceneImage, sobel_threshold, canny_threshold);
%     
%     % get the region includes the vehicle logo and head light
%     crop_image = vehicle_segment(sceneImage, x, y, w, h);
% 
%     % detect logo location with phase congruency
%     logo_region = phase_congruency(crop_image);
% 
%     % store the image
%     filename = sprintf('%s%s', output_dir_name, MyFolderInfo(i).name);
%     imwrite(logo_region, filename);
%     fprintf('%d: Save image %s\n', i, filename);    
% 
% end