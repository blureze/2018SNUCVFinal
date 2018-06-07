% This method used LPL and sliding window approach to get the logo localization
% the sliding window approach is from the paper of 'Vehicle logo
% recognition in traffic images using HOG features and SVM' by Llorca

% This approach assumes that the logo is just above the license plate, then
% used a square window to scan the area along vertical axis.


%% initialize
sobel_threshold = 0.2;
canny_threshold = 0.6;
%% single file
% % load image
% sceneImage = im2double(imread('../car/nissan/IMG_0378.jpg'));
% sceneImage = rgb2gray(sceneImage);
% sceneImage_scale = imresize(sceneImage, [480,640]);
% % figure, imshow(sceneImage);
% 
% % get the coordinate of vehical license
% [license_image, x, y, w, h] = license_detection(sceneImage_scale, sobel_threshold, canny_threshold, 1);
% figure, imshow(license_image);
% title('License Plate');
% 
% % get vehicle logo region with squares of different sizes
% moving_step = 3;
% max_sliding_distance_pixel = y - h*2;
% if max_sliding_distance_pixel < 1
%     max_sliding_distance_pixel = 1;
% end
% sliding_times = round(max_sliding_distance_pixel/moving_step);
% 
% sizes = [round(w/6), round(w/5), round(w/4), round(w/3), round(w/2)];
% 
% output_dir_name = '../car/nissan/logo/';
% 
% for i = 1:numel(sizes)
%     % slide the window alone the vertical axis
%     new_x = x + round(w/2 - sizes(i)/2);
%     new_y = y - round(sizes(i));
%     new_w = round(sizes(i));
%     new_h = round(sizes(i));
%     
%     rectangle('Position', [new_x,new_y,new_w,new_h], 'EdgeColor','b');
%     
%     % save save the image
%     logo_region = sceneImage_scale(new_y: new_y+new_h-1, new_x:new_x+new_w-1);
%     filename = sprintf('%s%d-0.jpg', output_dir_name, i);
%     imwrite(logo_region, filename);
%     fprintf('%d-0: Save image %s\n', i, filename);
%     
%     for j = 1:sliding_times
%         new_y = new_y - 3*j;
%         if new_y < max_sliding_distance_pixel
%             break;
%         end
%         rectangle('Position', [new_x,new_y,new_w,new_h], 'EdgeColor','b');
%        
%         % save save the image
%         logo_region = sceneImage_scale(new_y: new_y+new_h-1, new_x:new_x+new_w-1);
%         filename = sprintf('%s%d-%d.jpg', output_dir_name, i, j);
%         imwrite(logo_region, filename);
%         fprintf('%d-%d: Save image %s\n', i, j, filename);
%     end
%     
% end


%% all files in directory
input_dir_name = '../car/nissan/';
output_dir_name = '../car/nissan/license/';
MyFolderInfo = dir(input_dir_name);

for i = 4: numel(MyFolderInfo) % the first 3 components are '.', '..', '.DS_Store'
    
    img_dir = sprintf('%s%s', input_dir_name,MyFolderInfo(i).name);

    sceneImage = im2double(imread(img_dir));
    sceneImage = rgb2gray(sceneImage);
    sceneImage_scale = imresize(sceneImage, [480,640]);

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