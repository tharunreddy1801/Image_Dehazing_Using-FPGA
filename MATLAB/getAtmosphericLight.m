function A = getAtmosphericLight(img, darkChannel)
    % Find top 0.1% brightest pixels in the dark channel
    numPixels = size(darkChannel, 1) * size(darkChannel, 2);
    topPixels = ceil(0.001 * numPixels);
    
    darkChannelVec = reshape(darkChannel, [], 1);
    indices = 1:numPixels;
    
    % Perform a simple descending sort using selection sort for top values
    for i = 1:topPixels
        maxIndex = i;
        for j = i+1:numPixels
            if darkChannelVec(j) > darkChannelVec(maxIndex)
                maxIndex = j;
            end
        end
        % Swap values
        tempValue = darkChannelVec(i);
        darkChannelVec(i) = darkChannelVec(maxIndex);
        darkChannelVec(maxIndex) = tempValue;
        
        tempIndex = indices(i);
        indices(i) = indices(maxIndex);
        indices(maxIndex) = tempIndex;
    end
    
    brightestIndices = indices(1:topPixels);
    
    % Estimate A as the max intensity of those pixels in the input image
    [h, w, ~] = size(img);
    imgVec = reshape(img, h * w, 3);
    
    A = [0, 0, 0];
    for i = 1:topPixels
        pixel = imgVec(brightestIndices(i), :);
        A(1) = max(A(1), pixel(1));
        A(2) = max(A(2), pixel(2));
        A(3) = max(A(3), pixel(3));
    end
end