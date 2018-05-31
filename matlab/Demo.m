%% initialize
% dir = './Front-view-Cars/buick/img';
sobel_threshold = 0.2;
canny_threshold = 0.6;
flag = 0;

sceneImage = im2double(imread('../small sample/10.jpg'));
sceneImage = rgb2gray(sceneImage);
I1 = sceneImage;

% logo should be within the region where the car exists
[upper_bound, lower_bound, left_bound, right_bound] = car_extraction(sceneImage, canny_threshold);

while 1
    % step 0: edge detection
    I1_edge = edge(I1,'sobel', sobel_threshold);
%     figure, imshow(I1_edge);
    
    % step 1: SCW
    Iand = SCW(I1_edge, 6, 2, 12, 4, 0.7, 'mean');
%     figure, imshow(Iand);
    
    % step 2: masking
    I2 = I1 .* Iand;
    I2(1:upper_bound, :) = 0;
    I2(lower_bound:end, :) = 0;
    I2(:, 1:left_bound) = 0;
    I2(:, right_bound:end) = 0;
%     figure, imshow(I2);

%     % step 3: sauvola
%     I3 = sauvola(I2, [15 15], 0.3);
% %     figure, imshow(I3);

    % step 4: get property of each object and select those with: 
    % 2 < 'Aspect Ratio'< 6, 'EulerNumber' > 3, 'Orientation' < 35
    cc = bwconncomp(I2);
    labeled = labelmatrix(cc);
%     RGB_label = label2rgb(labeled, @copper, 'c', 'shuffle');
%     figure, imshow(RGB_label,'InitialMagnification','fit');
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
            break;
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

%% plate processing
% for i = 1:n
%     x_min = fix(matrix(i, 1));
%     x_max = fix(matrix(i, 2));
%     y_min = fix(matrix(i, 3));
%     y_max = fix(matrix(i, 4));
%     
%     % step 1: crop the image
%     I5 = sceneImage(y_min:y_max, x_min:x_max);
%     
%     % step 2: resize to 75x228
%     I5 = imresize(I5, [75, 228]);
%     
%     % step 3: SCW
%     I6 = SCW(I5, 2, 5, 4, 10, 1.3, 'std');
%     
%     % step 4: inverse I6
%     I7 = 1-I6;
%     
%     % step 5: binary measurement on I7
%     cc = bwconncomp(I7);
%     stats1 = regionprops(cc, 'Extrema', 'Orientation');
%     
%     selected_objects = zeros(1, numel(stats1));
%     I8 = I7;
%     for j = 1: numel(stats1)
%         
%         % calculate height
%         height = max(stats1(j).Extrema(:,2)) - min(stats1(j).Extrema(:,2)) +1;
%         
%         if (height > 32) && (stats1(j).Orientation > 75)
%             selected_objects(j) = 1;
%             
%             % delete it from I7
%             I8(min(stats1(j).Extrema(:,2)):max(stats1(j).Extrema(:,2)), min(stats1(j).Extrema(:,1)):max(stats1(j).Extrema(:,1))) = 0;
%         end
%     end
%     
%     % step 6: find bounding box in I8
%     cc = bwconncomp(I8);
%     stats1 = regionprops(cc, 'BoundingBox');
%     
% end

%% show region

figure, imshow(sceneImage);
hold on;

for i = 1:n
    x = matrix(i,1);
    y = matrix(i,3);
    w = matrix(i,2) - matrix(i,1);
    h = matrix(i,4) - matrix(i,3);
    rectangle('Position', [x,y,w,h], 'EdgeColor','r');
end

