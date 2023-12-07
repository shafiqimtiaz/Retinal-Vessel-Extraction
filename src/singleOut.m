%Clear Memory & Command Window
clc;
clear all;
close all;

% image ref from 21 - 40
imageRef = 33;

% Convert the integer to string
strImageCount = num2str(imageRef);

% Load the image
image = imread(['images\' strImageCount '_training.tif']);
groundTruth = imread(['ground_truth\' strImageCount '_training.png']);

% Convert to grayscale if necessary
image = rgb2gray(image);

% Histogram equalization
img = adapthisteq(image);

% Define the parameters
s = 2.5; % scale of the filter
t = 7; % criterion

L =  s; % length of the neighborhood along the y-axis
c = 3; % constant for threshold level calculation
w = 3; % size of the mean filter
se = 1; % param for Morphological opening and closing
minP = 20; % Define the minimum particle size

% Create the matched filter
x = -t*s:1:t*s;
y = -L/2:1:L/2;
[X, ~] = meshgrid(x, y);

m = (1/(2*t*s))*trapz(x, (1/sqrt(2*pi*s))*exp(-(x.^2)/(2*s^2)));
f = (1/sqrt(2*pi*s))*exp(-(X.^2)/(2*s^2)) - m;

% Create the first-order derivative of Gaussian (FDOG)
g = (X/(sqrt(2*pi*s^3))).*exp(-(X.^2)/(2*s^2));

% Initialize the output image
vessels = false(size(img));

% Initialize a subplot
figure;

% Apply the filters to the image in 8 directions
for theta = 0:45:315
    % Rotate the filters
    f_rot = imrotate(f, theta, 'bilinear', 'crop');
    g_rot = imrotate(g, theta, 'bilinear', 'crop');

    % Apply the rotated filters to the image
    H = imfilter(img, f_rot, 'replicate');
    D = imfilter(img, g_rot, 'replicate');

    % Calculate the local mean image of D
    W = ones(w, w) / w^2;
    Dm = imfilter(D, W, 'replicate');

    % Normalize Dm to [0, 1]
    Dm = Dm / max(Dm(:));

    % Calculate the threshold T
    mH = mean(H(:));
    Tc = c * mH;
    T = (1 + mean(Dm(:))) * Tc;

    % Threshold the image
    vessels_thres = H > T;

    % Morphological post-processing
    vessels_rot = imopen(vessels_thres, strel('disk', se));
    vessels_rot = imclose(vessels_rot, strel('disk', se));
    
    % Remove small noise particles
    vessels_rot = bwareaopen(vessels_rot, minP);

    % Combine the results
    vessels = vessels | vessels_rot;

    % Plot the results in subplots
    subplot(3, 3, theta/45 + 1);
    imshow(H, []);
    title(['H for \theta = ' num2str(theta) ' degrees']);
    
    subplot(3, 3, theta/45 + 2);
    imshow(D, []);
    title(['D for \theta = ' num2str(theta) ' degrees']);

end

% Morphological post-processing
vessels_morph = imopen(vessels, strel('disk', se * 2));
vessels_morph = imclose(vessels_morph, strel('disk', se));

% Display the final result
figure;

subplot(2, 3, 1);
imshow(img); title('Histogram equalized');

subplot(2, 3, 2);
imshow(ground_truth);
title('Ground Truth');

subplot(2, 3, 3);
imshow(vessels_morph);
title('Extracted Blood Vessels');

subplot(2, 3, [4,5,6]);
imshowpair(vessels_morph, ground_truth, 'montage');
title('Comparison');