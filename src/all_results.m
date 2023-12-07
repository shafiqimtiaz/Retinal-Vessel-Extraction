%Clear Memory & Command Window
clc; clear all; close all;

% Define the parameters
t = 3; % criterion
c = 2.3; % constant for threshold level calculation
w = 31; % size of the mean filter w x w
se = 1; % param for Morphological opening and closing
minP = 50; % Define the minimum particle size

% Define the parameters for wide vessels
s_wide = 1.3; % scale of the filter
L_wide = 7; % length of the neighborhood along the y-axis

% Define the parameters for thin vessels
s_thin = 0.8; % scale of the filter
L_thin = 4; % length of the neighborhood along the y-axis

% Create a figure
figure;

% Loop over imageRef from 21 to 40
for imageRef = 21:40
    % Convert the integer to string
    strImageCount = num2str(imageRef);

    % Load the image
    image = imread(['images\' strImageCount '_training.tif']);
    groundTruth = imread(['ground_truth\' strImageCount '_training.png']);

    % Convert to grayscale if necessary
    image = rgb2gray(image);

    % Histogram equalization
    img = adapthisteq(image);

    % Apply the MF-FDOG approach for wide vessels
    vessels_wide = apply_MF_FDOG(img, s_wide, t, L_wide, c, w, se, minP);

    % Apply the MF-FDOG approach for thin vessels
    vessels_thin = apply_MF_FDOG(img, s_thin, t, L_thin, c, w, se, minP);

    % Combine the results
    vessels = vessels_wide | vessels_thin;

    % Display the extracted vessels
    subplot(4, 5, imageRef - 20);
    imshow(vessels);
    title(['Extracted Vessels ' strImageCount]);
end
