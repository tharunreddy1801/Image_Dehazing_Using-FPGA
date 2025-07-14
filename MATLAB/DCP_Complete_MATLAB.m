clc; clear; close all;

hazyImg = im2double(imread("C:\Users\Rohan\Documents\Images\canyon.jpg"));
figure, imshow(hazyImg), title('Hazy Image');

patchSize = 15; 
omega = 0.9375;  
t0 = 0.25;    
r = 60;  
eps = 0.001; 

r = 2 * floor(r / 2) + 1;

darkChannel = getDarkChannel(hazyImg, patchSize);
figure, imshow(darkChannel), title('Dark Channel');

A = estimateAtmosphericLight(hazyImg, darkChannel);
disp(['Estimated Atmospheric Light: ', num2str(A)]);

rawTransmission = 1 - omega * darkChannel;
%figure, imshow(rawTransmission), title('Raw Transmission Map');
%disp(rawTransmission);

refinedTransmission = guidedFilter(hazyImg, rawTransmission, r, eps);
%figure, imshow(refinedTransmission), title('Refined Transmission Map');
%disp(refinedTransmission);

[h, w, ~] = size(hazyImg);
dehazedImg = zeros(h, w, 3);

for c = 1:3
    dehazedImg(:,:,c) = (hazyImg(:,:,c) - A(c)) ./ max(refinedTransmission, t0) + A(c);
end

dehazedImg = max(min(dehazedImg, 1), 0);
figure, imshow(dehazedImg), title('Dehazed Image');
dehazedImgSharp = imsharpen(dehazedImg);
figure, imshow(dehazedImgSharp), title('Sharpened Dehazed Image');
imwrite(dehazedImg, 'dehazed_canyon_512.bmp');
%%%%%

function darkChannel = getDarkChannel(img, patchSize)
    minRGB = min(img, [], 3); 
    darkChannel = imerode(minRGB, strel('square', patchSize));
end

function A = estimateAtmosphericLight(img, darkChannel)
    numPixels = numel(darkChannel);
    topPixels = ceil(0.001 * numPixels);
    
    [~, indices] = sort(darkChannel(:), 'descend');
    brightestIndices = indices(1:topPixels);
    
    [h, w, ~] = size(img);
    imgVec = reshape(img, h * w, 3);
    A = max(imgVec(brightestIndices, :));
end

function q = guidedFilter(I, p, r, eps)
    I = rgb2gray(I);
    mean_I = imboxfilt(I, [r r]);
    mean_p = imboxfilt(p, [r r]);
    corr_I = imboxfilt(I .* I, [r r]);
    corr_Ip = imboxfilt(I .* p, [r r]);

    var_I = corr_I - mean_I .* mean_I;
    cov_Ip = corr_Ip - mean_I .* mean_p;

    a = cov_Ip ./ (var_I + eps);
    b = mean_p - a .* mean_I;

    mean_a = imboxfilt(a, [r r]);
    mean_b = imboxfilt(b, [r r]);

    q = mean_a .* I + mean_b;
end
