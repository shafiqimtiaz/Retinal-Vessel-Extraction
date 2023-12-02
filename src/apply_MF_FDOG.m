function vessels = apply_MF_FDOG(img, s, t, L, c, w, se)
    % Create the matched filter
    x = -t*s:1:t*s;
    y = -L/2:1:L/2;
    [X, Y] = meshgrid(x, y);

    m = (1/(2*t*s))*trapz(x, (1/sqrt(2*pi*s))*exp(-(x.^2)/(2*s^2)));
    f = (1/sqrt(2*pi*s))*exp(-(X.^2)/(2*s^2)) - m;

    % Create the first-order derivative of Gaussian (FDOG)
    g = (X/(sqrt(2*pi*s^3))).*exp(-(X.^2)/(2*s^2));

    % Initialize the output image
    vessels = false(size(img));

    % Apply the filters to the image in 8 directions
    for theta = 0:45:315
        % Rotate the filters
        f_rot = imrotate(f, theta, 'bilinear', 'crop');
        g_rot = imrotate(g, theta, 'bilinear', 'crop');

        % Apply the rotated filters to the image
        H = imfilter(img, f_rot, 'symmetric');
        D = imfilter(img, g_rot, 'symmetric');

        % Calculate the local mean image of D
        W = ones(w, w) / w^2;
        Dm = imfilter(D, W, 'symmetric');

        % Normalize Dm to [0, 1]
        Dm = Dm / max(Dm(:));

        % Calculate the threshold T
        mH = mean(H(:));
        Tc = c * mH;
        T = (1 + mean(Dm(:))) * Tc;

        % Threshold the image
        vessels_thres = H > T;

        % Morphological post-processing
        vessels_rot = imopen(vessels_thres,  strel('disk', se));
        vessels_rot = imclose(vessels_rot,  strel('disk', se));

        % Combine the results
        vessels = vessels | vessels_rot;
    end
end