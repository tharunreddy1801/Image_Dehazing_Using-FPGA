function darkChannel = getDarkChannel(img, patchSize)
    [height, width, ~] = size(img);
    halfPatch = floor(patchSize / 2);
    
    % Compute the minimum across RGB channels
    minRGB = min(img, [], 3);
    
    % Initialize the dark channel with zeros
    darkChannel = zeros(height, width);
    
    for i = 1:height
        for j = 1:width
            % Define window boundaries with boundary checks
            rowMin = max(1, i - halfPatch);
            rowMax = min(height, i + halfPatch);
            colMin = max(1, j - halfPatch);
            colMax = min(width, j + halfPatch);
            
            % Extract and find the minimum in the window
            window = minRGB(rowMin:rowMax, colMin:colMax);
            darkChannel(i, j) = min(window(:));
        end
    end
end