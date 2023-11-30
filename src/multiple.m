%Clear Memory & Command Window
clc;
clear all;
close all;

% Load the image
image = imread('Input.bmp');

% Convert to grayscale if necessary
image = rgb2gray(image);

% Histogram equalization
img = adapthisteq(image);

% Define the parameters
c = 3; % constant for threshold level calculation
w = 3; % size of the mean filter
se = 1; % param for Morphological opening and closing

% Iterate over s and t
[s_values, t_values] = fine_tune(1, 0.5, 5, 5, 10);
% Total number of subplots
total_plots = length(s_values) * length(t_values);
% Counter for current subplot
plot_counter = 1;

for i = 1:length(s_values)
    for j = 1:length(t_values)
        s = s_values(i); % scale of the filter
        t = t_values(j); % criterion
        L = s; % length of the neighborhood along the y-axis

        % Process the image
        vessels = process_image(img, s, t, L, c, w, se);

        % Display the extracted vessels
        figure(1)
        subplot(ceil(sqrt(total_plots)), ceil(sqrt(total_plots)), plot_counter);
        imshow(vessels);
        title(['s = ', num2str(s), ', t = ', num2str(t)]);
        
        % Increment plot counter
        plot_counter = plot_counter + 1;
    end
end

function [s_values, t_values] = fine_tune(start_s, step_s, end_s, start_t, end_t)
    s_values = start_s:step_s:end_s;
    num_elements = length(s_values);
    
    % Calculate the step size for t_values based on the number of elements in s_values
    step_t = (end_t - start_t) / (num_elements - 1);
    
    t_values = start_t:step_t:end_t;
end

function vessels = process_image(img, s, t, L, c, w, se)
    % Create the matched filter
    x = -t*s:1:t*s;
    y = -L/2:1:L/2;
    [X, ~] = meshgrid(x, y);

    m = (1/(2*t*s))*trapz((1/sqrt(2*pi*s))*exp(-(x.^2)/(2*s^2)));
    f = (1/sqrt(2*pi*s))*exp(-(X.^2)/(2*s^2)) - m;

    % Create the first-order derivative of Gaussian (FDOG)
    g = (X/(sqrt(2*pi*s^3))).*exp(-(X.^2)/(2*s^2));

    % Apply the filters to the image
    H = imfilter(img, f, 'replicate');
    D = imfilter(img, g, 'circular');

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
    vessels = H > T;

    % Morphological post-processing
    vessels = imopen(vessels,  strel('square', se));
    vessels = imclose(vessels,  strel('disk', se * 3));
end