function [logo_region, min_x, max_x] = phase_congruency(crop_image)

[M, m, or, ft, pc, EO] = phasecong2(crop_image);
pc_value = abs(EO{1,1});
pc_value = sum(pc_value); 
[gx, gy] = imgradientxy(pc_value);
threshold = quantile(gx, 0.7);
pixels = find(gx >= threshold);   % find the pixels on x-axis that are below the threshold

if ~isempty(pixels) && numel(pixels) >= 5
    min_index = round(numel(pixels)/5*2);
    max_index = round(numel(pixels)/5*3);
    
    min_x = pixels(min_index);
    max_x = pixels(max_index);

    logo_region = crop_image(:,min_x:max_x);
else
    logo_region = crop_image;
end