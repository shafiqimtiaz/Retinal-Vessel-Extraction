% Load the image
image = imread('Input.bmp');

% Convert to grayscale if necessary
if size(image, 3) == 3
    image = rgb2gray(image);
end

% Convert to double
img = double(image);

% Define the parameters
s = 3; % scale of the filter
t = 5; % criterion
L = 1; % length of the neighborhood along the y-axis

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
w = 3; % size of the mean filter
W = ones(w, w) / w^2;
Dm = imfilter(D, W, 'replicate');

% Normalize Dm to [0, 1]
Dm = Dm / max(Dm(:));

% Set the threshold
Tc = 3; % threshold level
T = (1 + mean(Dm(:))) * Tc;

% Threshold the image
vessels = H > T;

% Display the extracted vessels
figure;
subplot(121);imshow(image);title('Input Image');
subplot(122);imshow(vessels);title('Extracted Blood Vessels');