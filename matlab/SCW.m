function Iand = SCW(img, x1, y1, x2, y2, threshold)

[row, col] = size(img);
Iand = zeros(row, col);

% image padding
img_padding = padarray(img,[y2 x2],'replicate','both');

% scan the image
for i = 1:row
    for j = 1:col
        % create window A and window B
        windowA = img_padding(i+y2-y1:i+y2+y1-1, j+x2-x1:j+x2+x1-1);
        windowB = img_padding(i:i+2*y2-1, j:j+2*x2-1);
        
        % compute Ma and Mb
        Ma = mean(windowA(:));
        Mb = mean(windowB(:));

%         
       % compare Mb/Ma with threshold
       t = Mb/Ma;
       
       if t > threshold
           Iand(i,j) = 1;
       end
    end
end



