function [license_image, x, y, w, h] = logo_detection(sceneImage, sobel_threshold, canny_threshold)
%% initialize
flag = 0;
I1 = sceneImage;
license_image = [];
x = 1;
y = 1;
[h, w] = size(sceneImage);


% logo should be within the region where the car exists
[upper_bound, lower_bound, left_bound, right_bound] = car_extraction(sceneImage, canny_threshold);

while 1
    % step 0: edge detection
    I1_edge = edge(I1,'sobel', sobel_threshold);
%     figure, imshow(I1_edge);
    % step 1: SCW
    Iand = SCW(I1_edge, 6, 2, 12, 4, 0.7);
%     figure, imshow(Iand);
    
    
    % step 2: masking
    I2 = I1 .* Iand;
    I2(1:upper_bound, :) = 0;
    I2(lower_bound:end, :) = 0;
    I2(:, 1:left_bound) = 0;
    I2(:, right_bound:end) = 0;
%     figure, imshow(I2);

    % step 4: get property of each object and select those with: 
    % 2 < 'Aspect Ratio'< 6, 'Orientation' < 35
    cc = bwconncomp(I2);
    stats = regionprops(cc, 'Extrema', 'Orientation');

    selected_objects = zeros(1, numel(stats));
    for i = 1: numel(stats)
        % calculate aspect ration
        c = max(stats(i).Extrema(:,1)) - min(stats(i).Extrema(:,1));
        r = max(stats(i).Extrema(:,2)) - min(stats(i).Extrema(:,2));
        ar = c/r;

        if (ar > 2 && ar < 6) && (stats(i).Orientation < 35) && (c > 90 && r > 30)
            selected_objects(i) = 1;
        end
    end

    % step 5: how many objects are selected
    n = numel(find(selected_objects));

    if flag == 0    % not inverse
        if n > 0
            break;
        elseif n == 0
            flag = 1;
            I1 = 1-I1;
        end
    else
        if n == 0
            fprintf('No license plates found.\n');
            return;
        else
            break;
        end
    end
end


% step 6: detect coordinates of Xmin Xmax Ymin Ymax for each object i

object_ids = find(selected_objects);
matrix = zeros(n, 4);

for i = 1:n
    x_min = min(stats(object_ids(i)).Extrema(:,1));
    x_max = max(stats(object_ids(i)).Extrema(:,1));
    y_min = min(stats(object_ids(i)).Extrema(:,2));
    y_max = max(stats(object_ids(i)).Extrema(:,2));

    matrix(i, :) = [x_min, x_max, y_min, y_max];
end

%% find license plate (find the region that contains the most texts with MSER)
possible_id = 1;
max_text_count = 0;

for i = 1:n
    x_min = fix(matrix(i, 1));
    x_max = fix(matrix(i, 2));
    y_min = fix(matrix(i, 3));
    y_max = fix(matrix(i, 4));
    
    % step 1: crop the image
    I5 = sceneImage(y_min:y_max, x_min:x_max);
    
    % step 2: Detect MSER regions.
    [mserRegions, mserConnComp] = detectMSERFeatures(I5, 'RegionAreaRange',[30 14000],'ThresholdDelta',4);
    
    % step 2-1: remove non-text region
        % Use regionprops to measure MSER properties
        mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
            'Solidity', 'Extent', 'Euler', 'Image');

        % Compute the aspect ratio using bounding box data.
        bbox = vertcat(mserStats.BoundingBox);
        w = bbox(:,3);
        h = bbox(:,4);
        aspectRatio = w./h;

        % Threshold the data to determine which regions to remove. These thresholds
        % may need to be tuned for other images.
        filterIdx = aspectRatio' > 3; 
        filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
        filterIdx = filterIdx | [mserStats.Solidity] < .3;
        filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
        filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

        % Remove regions
        mserStats(filterIdx) = [];
        mserRegions(filterIdx) = [];

    % step 3: find the most possible region of the license
    if mserRegions.Count > max_text_count
        max_text_count = mserRegions.Count;
        possible_id = i;
    end
    
end

%% show region

% figure, imshow(sceneImage);
% hold on;

x = fix(matrix(possible_id,1));
y = fix(matrix(possible_id,3));
w = fix(matrix(possible_id,2) - matrix(possible_id,1));
h = fix(matrix(possible_id,4) - matrix(possible_id,3));
% rectangle('Position', [x,y,w,h], 'EdgeColor','r');

% crop the image
license_image = sceneImage(y: y+h-1, x:x+w-1);


% k = 2;
% y = matrix(possible_id,3);
% h = matrix(possible_id,4) - matrix(possible_id,3);
% 
% new_y = fix(y - k*h);
% 
% if new_y < 1
%     new_y = 1;
% end
% 
% crop_image = sceneImage(new_y: fix(matrix(possible_id,4)), fix(matrix(possible_id,1)):fix(matrix(possible_id,2)));
