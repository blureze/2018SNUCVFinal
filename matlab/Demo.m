%% initialize
% dir = './Front-view-Cars/buick/img';
threshold = 0.2;
flag = 0;

sceneImage = im2double(imread('../small sample/10.jpg'));
sceneImage = rgb2gray(sceneImage);
I1 = sceneImage;

while 1
    % step 0: edge detection
    I1_edge = edge(I1,'sobel', threshold);
%     figure, imshow(I1_edge);
    
    % step 1: SCW
    Iand = SCW(I1_edge, 6, 2, 12, 4, 0.7);
%     figure, imshow(Iand);
    
    % step 2: masking
    I2 = I1 .* Iand;
    figure, imshow(I2);

%     % step 3: sauvola
%     I3 = sauvola(I2, [15 15], 0.3);
% %     figure, imshow(I3);

    % step 4: get property of each object and select those with: 
    % 2 < 'Aspect Ratio'< 6, 'EulerNumber' > 3, 'Orientation' < 35
    cc = bwconncomp(I2);
    labeled = labelmatrix(cc);
    RGB_label = label2rgb(labeled, @copper, 'c', 'shuffle');
%     figure, imshow(RGB_label,'InitialMagnification','fit');
    stats = regionprops(cc, 'Extrema', 'EulerNumber', 'Orientation');

    selected_objects = zeros(1, numel(stats));
    for i = 1: numel(stats)
        % calculate aspect ration
        c = max(stats(i).Extrema(:,1)) - min(stats(i).Extrema(:,1)) +1;
        r = max(stats(i).Extrema(:,2)) - min(stats(i).Extrema(:,2)) +1;
        ar = c/r;

        if (ar > 2 && ar < 6) && stats(i).Orientation < 35
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
            I1 = -I1;
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
    x_min = min(stats(i).Extrema(:,1));
    x_max = max(stats(i).Extrema(:,1));
    y_min = min(stats(i).Extrema(:,2));
    y_max = max(stats(i).Extrema(:,2));
    
    matrix(i, :) = [x_min, x_max, y_min, y_max];
end

    
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

