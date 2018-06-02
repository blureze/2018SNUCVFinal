function [upper_bound, lower_bound, left_bound, right_bound] = car_extraction(sceneImage_gray, threshold)
% load image
% sceneImage = imread('./small sample/10.jpg');
% sceneImage_gray = rgb2gray(sceneImage);

[row, col] = size(sceneImage_gray);

% edge detection
BW2 = edge(sceneImage_gray,'canny', threshold);
% figure, imshow(BW2);

% found the boundary
% find upper bound
for i = 1:row
    if ~isempty(find(BW2(i,:)))
        lower_bound = i;
    end
end

% find lower bound
for i = row:-1:1
    if ~isempty(find(BW2(i,:)))
        upper_bound = i;
    end
end

% find left bound
for i = 1:col
    if ~isempty(find(BW2(:,i)))
        right_bound = i;
    end
end

% find right bound
for i = col:-1:1
    if ~isempty(find(BW2(:,i)))
        left_bound = i;
    end
end

crop_img =  sceneImage_gray(upper_bound:lower_bound, left_bound:right_bound);
% figure, imshow(crop_img);
% imwrite(crop_img, filename);
