%Clear Memory & Command Window
clc; close all;

% Load the image
image = imread('images\21_training.tif');

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

% Create the matched filter
x = -t*s:1:t*s;
y = -L/2:1:L/2;
[X, Y] = meshgrid(x, y);

m = (1/(2*t*s))*trapz(x, (1/sqrt(2*pi*s))*exp(-(x.^2)/(2*s^2)));
f = (1/sqrt(2*pi*s))*exp(-(X.^2)/(2*s^2)) - m;

% Create the first-order derivative of Gaussian (FDOG)
g = (X/(sqrt(2*pi*s^3))).*exp(-(X.^2)/(2*s^2));

% Apply the filters to the image
H = imfilter(img, f, 'symmetric');
D = imfilter(img, g, 'symmetric');

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
vessels_morph = imopen(vessels_thres,  strel('disk', se * 2));
vessels_morph = imclose(vessels_morph,  strel('disk', se));

% Display the extracted vessels
figure;
subplot(321);imshow(image);title('Input Image');
subplot(322);imshow(img);title('Histogram equalized');
subplot(323);imshow(H);title('Filtered by MF');
subplot(324);imshow(D);title('Filtered by FDOG');
subplot(325);imshow(vessels_thres);title('Thresholded');
subplot(326);imshow(vessels_morph);title('Extracted Blood Vessels');