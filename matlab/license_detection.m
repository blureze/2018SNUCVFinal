function [license_image, x, y, w, h] = license_detection(sceneImage, sobel_threshold, canny_threshold, useMSER)
%% initialize
flag = 0;
I1 = sceneImage;
license_image = sceneImage;
x = 1;
y = 1;
[h, w] = size(sceneImage);


% logo should be within the region where the car exists
[upper_bound, lower_bound, left_bound, right_bound] = car_extraction(sceneImage, canny_threshold);

while 1
    % step 0: edge detection
    I1_edge = edge(I1,'sobel', sobel_threshold);
%       I1_edge = watershed(I1);

    figure, imshow(I1_edge);
    % step 1: SCW
    Iand = SCW(I1_edge, 6, 2, 12, 4, 0.7);
    figure, imshow(Iand);
    
    % step 2: masking
    I2 = I1 .* Iand;
    I2(1:upper_bound, :) = 0;
    I2(lower_bound:end, :) = 0;
    I2(:, 1:left_bound) = 0;
    I2(:, right_bound:end) = 0;
    figure, imshow(I2);

    % step 4: get property of each object and select those with: 
    % 2 < 'Aspect Ratio'< 6, 'Orientation' < 35
    cc = bwconncomp(I2);
    stats = regionprops(cc, 'Extrema', 'Orientation', 'EulerNumber', 'BoundingBox');

    selected_objects = zeros(1, numel(stats));
    for i = 1: numel(stats)
        % calculate aspect ration
        c = max(stats(i).Extrema(:,1)) - min(stats(i).Extrema(:,1));
        r = max(stats(i).Extrema(:,2)) - min(stats(i).Extrema(:,2));
        ar = c/r;

        if (ar > 3 && ar < 5) && (stats(i).Orientation < 35) && (c > 90 && r > 30) && (stats(i).EulerNumber < -3)
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
if useMSER == 1 
    possible_id = 1;
    min_text_count = inf;

    for i = 1:n
        x_min = fix(matrix(i, 1));
        x_max = fix(matrix(i, 2));
        y_min = fix(matrix(i, 3));
        y_max = fix(matrix(i, 4));

        % step 1: crop the image
        I5 = sceneImage(y_min:y_max, x_min:x_max);
        I5_large = imresize(I5, 5);
%         figure, imshow(I5);

        % step 2: Detect MSER regions and use OCR to detect regions that has most possible text.

        [ITextRegion, textBBoxes] = MSER(I5_large);

        if isempty(ITextRegion) || isempty(textBBoxes)
            return;
        end
        ocrtxt = ocr(I5_large, textBBoxes);

        % step 3: find the most possible region of the license
        % calculate the word confidence
        word_conf = zeros(1, numel(ocrtxt));
        for j = 1:numel(ocrtxt)
            if ~isempty(ocrtxt(j).WordConfidences)
                word_conf = mean(ocrtxt(j).WordConfidences);
            end
        end
        word_conf = mean(word_conf);

        if ~isempty([ocrtxt.Text]) && (size(textBBoxes,1) < min_text_count) && (word_conf > 0.5)
            min_text_count = size(textBBoxes,1);
            possible_id = i;
        elseif size(textBBoxes,1) == min_text_count
            candidate = sceneImage(fix(matrix(possible_id, 3)):fix(matrix(possible_id, 4)), fix(matrix(possible_id, 1)):fix(matrix(possible_id, 2)));

            if numel(I5_large) < numel(candidate)
                possible_id = i;
            end
        end
    end
end

%% show region

if useMSER == 1
    figure, imshow(sceneImage);
    hold on;

    x = fix(matrix(possible_id,1));
    y = fix(matrix(possible_id,3));
    w = fix(matrix(possible_id,2) - matrix(possible_id,1));
    h = fix(matrix(possible_id,4) - matrix(possible_id,3));
    rectangle('Position', [x,y,w,h], 'EdgeColor','r');

    % crop the image
    license_image = sceneImage(y: y+h-1, x:x+w-1);
else
    license_image = cell(1,n);
    for i = 1:n
        x_min = fix(matrix(i, 1));
        x_max = fix(matrix(i, 2));
        y_min = fix(matrix(i, 3));
        y_max = fix(matrix(i, 4));

        % crop the image
        crop_image = sceneImage(y_min:y_max, x_min:x_max);
        license_image{i} = crop_image;
%         figure, imshow(crop_image);
    end
end


