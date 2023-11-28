%Clear Memory & Command Window
clc;
clear all;
close all;

% Load the image
image = imread('Input.bmp');

% Convert to grayscale if necessary
if size(image, 3) == 3
    image = rgb2gray(image);
end

% Histogram equalization
img = histeq(image);

% Define the parameters
s = 2.5; % scale of the filter
t = 4.5; % criterion
L = 2; % length of the neighborhood along the y-axis
c = 1; % constant for threshold level calculation
w = 2; % size of the mean filter
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
H = imfilter(img, f, 'replicate');
D = imfilter(img, g, 'replicate');

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
vessels = H > T;

% Morphological post-processing
strucElem = strel('disk', se);
vessels = imopen(vessels, strucElem);
vessels = imclose(vessels, strucElem);

% Display the extracted vessels
figure;
subplot(121);imshow(image);title('Input Image');
subplot(122);imshow(vessels);title('Extracted Blood Vessels');