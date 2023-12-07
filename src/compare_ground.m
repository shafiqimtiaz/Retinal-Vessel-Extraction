%Clear Memory & Command Window
clc; clear all; close all;

% image ref from 21 - 40
imageRef = 21;

% Convert the integer to string
strImageCount = num2str(imageRef);

% Load the image
image = imread(['images\' strImageCount '_training.tif']);
groundTruth = imread(['ground_truth\' strImageCount '_training.png']);

% Convert to grayscale if necessary
image = rgb2gray(image);

% Histogram equalization
img = adapthisteq(image);

% Core pamameters
t = 3; % criterion
c = 2.3; % constant for threshold level calculation
w = 31; % size of the mean filter w x w
se = 1; % param for Morphological opening and closing
minP = 50; % Define the minimum particle size

% Param in Paper
% wide: s = 1.5, L = 9
% wide: s = 1, L = 5

% Define the parameters for wide vessels
s = 1.3; % scale of the filter
L = 7; % length of the neighborhood along the y-axis

% Apply the MF-FDOG approach for wide vessels
vessels_wide = apply_MF_FDOG(img, s, t, L, c, w, se, minP);

% Define the parameters for thin vessels
s = 0.8; % scale of the filter
L = 4; % length of the neighborhood along the y-axis

% Apply the MF-FDOG approach for thin vessels
vessels_thin = apply_MF_FDOG(img, s, t, L, c, w, se, minP);

% Combine the results
vessels = vessels_wide | vessels_thin;

% Display the extracted vessels
figure;
row = 1; col = 3;
subplot(row, col, 1);imshow(image);title(['Input Image ' strImageCount]);
subplot(row, col, 2);imshow(groundTruth);title(['Ground Truth ' strImageCount]);
subplot(row, col, 3);imshow(vessels);title(['Extracted Vessels ' strImageCount]);