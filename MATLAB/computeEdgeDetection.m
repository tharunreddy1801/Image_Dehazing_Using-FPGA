function ED = computeEdgeDetection(img, D)
    [height, width, ~] = size(img);
    ED = zeros(height, width);

    % Convert image to double for calculations
    img = double(img);

    for i = 2:height-1
        for j = 2:width-1
            edgeStrength = 0;

            % Check diagonal edges
            for c = 1:3 % For each color channel (R, G, B)
                if abs(img(i-1, j-1, c) - img(i+1, j+1, c)) >= D || ...
                   abs(img(i-1, j+1, c) - img(i+1, j-1, c)) >= D
                    edgeStrength = 2;
                    break; % No need to check further
                end
            end
            
            if edgeStrength == 0 % Only check vertical/horizontal if no diagonal edge
                for c = 1:3
                    if abs(img(i-1, j, c) - img(i+1, j, c)) >= D || ...
                       abs(img(i, j-1, c) - img(i, j+1, c)) >= D
                        edgeStrength = 1;
                        break;
                    end
                end
            end
            
            ED(i, j) = edgeStrength;
        end
    end
end
