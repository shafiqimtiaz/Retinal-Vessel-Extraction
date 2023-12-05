%Clear Memory & Command Window
clc; close all;

% Load the image
image = imread('images\21_training.tif');

% Convert to grayscale if necessary
image = rgb2gray(image);

% Histogram equalization
img = adapthisteq(image);

% Core pamameters
t = 3; % criterion
c = 2.3; % constant for threshold level calculation
w = 31; % size of the mean filter
se = 2; % param for Morphological opening and closing
minP = 20; % Define the minimum particle size

% Define the parameters for wide vessels
s = 1.5; % scale of the filter
L = 9; % length of the neighborhood along the y-axis

% Apply the MF-FDOG approach for wide vessels
vessels_wide = apply_MF_FDOG(img, s, t, L, c, w, se, minP);

% Define the parameters for thin vessels
s = 1; % scale of the filter
L = 5; % length of the neighborhood along the y-axis

% Apply the MF-FDOG approach for thin vessels
vessels_thin = apply_MF_FDOG(img, s, t, L, c, w, se, minP);

% Combine the results
vessels = vessels_wide | vessels_thin;

row = 2; col = 4;

% Display the extracted vessels
figure;
subplot(row, col, 1);imshow(image);title('Input Image');
subplot(row, col, 2);imshow(img);title('Histogram equalized');
subplot(row, col, 3);imshow(H);title('Filtered by MF');
subplot(row, col, 4);imshow(D);title('Filtered by FDOG');
subplot(row, col, 5);imshow(vessels_wide);title('Wide Vessels');
subplot(row, col, 6);imshow(vessels_thin);title('Thin Vessels');
subplot(row, col, 7);imshow(vessels);title('Extracted Vessels');