%Clear Memory & Command Window
clc;
close all;

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
se = 1; % param for Morphological opening and closing
minP = 50; % Define the minimum particle size

% Iterate over s and t
[s_values, l_values] = fine_tune(1, 0.15, 1.6, 5, 1, 9);
% Total number of subplots
total_plots = length(s_values) * length(l_values);
% Counter for current subplot
plot_counter = 1;

for i = 1:length(s_values)
    for j = 1:length(l_values)

        s_thin = s_values(i); % scale of the filter
        L_thin = l_values(j); % criterion

        % Apply the MF-FDOG approach for wide vesselss
        vessels_wide = apply_MF_FDOG(img, s_thin, t, L_thin, c, w, se, minP);
        
        s_thick = s_thin - 0.5;
        L_thick = L_thin - 3;
        
        % Apply the MF-FDOG approach for thin vessels
        vessels_thin = apply_MF_FDOG(img, s_thick, t, L_thick, c, w, se, minP);
        
        % Combine the results
        vessels = vessels_wide | vessels_thin;

        % Display the extracted vessels
        figure(1)
        subplot(ceil(sqrt(total_plots)), ceil(sqrt(total_plots)), plot_counter);
        imshow(vessels);
        title_str = ['(',num2str(s_thin), ' , ', num2str(L_thin), ') (', num2str(s_thick), ' , ', num2str(L_thick), ')'];
        title(title_str);
        
        % Increment plot counter
        plot_counter = plot_counter + 1;
    end
end

function [s_values, l_values] = fine_tune(start_s, step_s, end_s, start_l, step_l, end_l)
    s_values = start_s:step_s:end_s;
    l_values = start_l:step_l:end_l;
end
