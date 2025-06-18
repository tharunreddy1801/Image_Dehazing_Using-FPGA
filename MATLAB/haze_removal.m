% MATLAB Implementation of Fast and Efficient Haze Removal without Predefined Functions

function dehazed_image = haze_removal(image_path)
    image = im2double(imread(image_path));
    dark_channel = compute_dark_channel(image);
    atmo_light = estimate_atmospheric_light(image, dark_channel);
    transmission = estimate_transmission(image, atmo_light);
    refined_trans = refine_transmission(image, transmission);
    dehazed_image = recover_radiance(image, refined_trans, atmo_light);
    
    figure;
    subplot(1,2,1), imshow(image), title('Hazy Image');
    subplot(1,2,2), imshow(dehazed_image), title('Dehazed Image');
end

function dark_channel = compute_dark_channel(image, patch_size)
    if nargin < 2
        patch_size = 15;
    end
    [rows, cols, ~] = size(image);
    min_channel = min(image, [], 3);
    dark_channel = zeros(rows, cols);
    half_patch = floor(patch_size / 2);
    for i = 1+half_patch:rows-half_patch
        for j = 1+half_patch:cols-half_patch
            dark_channel(i,j) = min(min_channel(i-half_patch:i+half_patch, j-half_patch:j+half_patch), [], 'all');
        end
    end
end

function atmo_light = estimate_atmospheric_light(image, dark_channel)
    num_pixels = round(0.1 * numel(dark_channel));
    dark_vector = dark_channel(:);
    [~, indices] = sort(dark_vector, 'descend');
    top_indices = indices(1:num_pixels);
    top_pixels = image(top_indices);
    atmo_light = mean(top_pixels(:));
end

function transmission = estimate_transmission(image, atmo_light, omega, patch_size)
    if nargin < 3
        omega = 0.95;
        patch_size = 15;
    end
    norm_image = image ./ atmo_light;
    dark_channel = compute_dark_channel(norm_image, patch_size);
    transmission = 1 - omega * dark_channel;
end

function refined_trans = refine_transmission(image, transmission)
    [rows, cols] = size(transmission);
    refined_trans = transmission;
    for i = 2:rows-1
        for j = 2:cols-1
            refined_trans(i, j) = mean(mean(transmission(i-1:i+1, j-1:j+1)));
        end
    end
end

function J = recover_radiance(image, transmission, atmo_light, t_min)
    if nargin < 4
        t_min = 0.1;
    end
    transmission = max(transmission, t_min);
    J = (image - atmo_light) ./ transmission + atmo_light;
    J = max(min(J, 1), 0);
end
