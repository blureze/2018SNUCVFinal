function crop_image = vehicle_segment(sceneImage, x, y, w, h)
new_w = 4*w;
new_h = 3*h;
new_x = fix(x - (new_w - w)/2);
new_y = y - new_h;

if new_w > size(sceneImage,2)
    new_w = size(sceneImage,2);
end

if new_h > size(sceneImage,1)
    new_h = size(sceneImage,1);
end

if new_x < 1
    new_x = 1;
end

if new_x + new_w -1 > size(sceneImage,2)
    new_w = size(sceneImage,2)-new_x + 1;
end

if new_y < 1
    new_y = 1;
end

crop_image = sceneImage(new_y:new_y+new_h-1, new_x:new_x+new_w-1);
% draw the region
% figure, imshow(sceneImage);
% hold on;
% crop_image = sceneImage(new_y:new_y+new_h-1, new_x:new_x+new_w-1);
% rectangle('Position', [new_x,new_y,new_w,new_h], 'EdgeColor','r');
