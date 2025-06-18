function J_tilde = recoverSceneRadiance(img, A, t, beta)
    % Convert image to double for calculations
    img = double(img);

    % Define t0 (minimum transmission threshold)
    t0 = 0.25;
    
    % Ensure t is at least t0
    t = max(t, t0); 

    % Expand A to match image dimensions (H x W x 3)
    A = reshape(A, [1, 1, 3]); % Convert A to 1x1x3 for broadcasting
    A = repmat(A, [size(img, 1), size(img, 2), 1]); % Expand A to HxWx3

    % Expand t to match image dimensions (H x W x 3)
    t = repmat(t, [1, 1, 3]); % Expand t to HxWx3

    % Compute scene radiance J
    J = (img - A) ./ t + A;

    % Compute refined scene radiance J_tilde
    J_tilde = (A .^ beta) .* (J .^ (1 - beta));

    % Clip values to valid image range [0, 255]
    J_tilde = max(0, min(255, J_tilde));

    % Convert back to uint8 for display
    J_tilde = uint8(J_tilde);
end
