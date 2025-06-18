function P = computeTransmissionFilter(img, ED)
    [height, width, channels] = size(img);
    P = zeros(height, width, channels);
    
    % Convert image to double for computation
    img = double(img);
    
    for i = 2:height-1
        for j = 2:width-1
            for c = 1:channels % Loop over color channels (R, G, B)
                if ED(i, j) == 2
                    % Edge-preserving filter P2
                    P(i, j, c) = (2 * img(i-1, j-1, c) + img(i-1, j, c) + 2 * img(i-1, j+1, c) + ...
                                  img(i, j-1, c) + 4 * img(i, j, c) + img(i, j+1, c) + ...
                                  2 * img(i+1, j-1, c) + img(i+1, j, c) + 2 * img(i+1, j+1, c)) / 16;
                elseif ED(i, j) == 1
                    % Edge-preserving filter P1
                    P(i, j, c) = (img(i-1, j-1, c) + 2 * img(i-1, j, c) + img(i-1, j+1, c) + ...
                                  2 * img(i, j-1, c) + 4 * img(i, j, c) + 2 * img(i, j+1, c) + ...
                                  img(i+1, j-1, c) + 2 * img(i+1, j, c) + img(i+1, j+1, c)) / 16;
                else
                    % Mean filter P0
                    P(i, j, c) = (img(i-1, j-1, c) + img(i-1, j, c) + img(i-1, j+1, c) + ...
                                  img(i, j-1, c) + img(i, j, c) + img(i, j+1, c) + ...
                                  img(i+1, j-1, c) + img(i+1, j, c) + img(i+1, j+1, c)) / 9;
                end
            end
        end
    end
end
