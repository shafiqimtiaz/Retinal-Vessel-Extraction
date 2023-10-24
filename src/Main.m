%Clear Memory & Command Window
clc;
clear all;
close all;

%Read Input Retina Image
inImg = imread('Input.bmp');
dim = ndims(inImg);
if(dim == 3)
    %Input is a color image
    inImg = rgb2gray(inImg);
end

%Extract Blood Vessels
Threshold = 30;
bloodVessels = RetinalExtract(inImg, Threshold);

%Output Blood Vessels image

figure;
subplot(121);imshow(inImg);title('Input Image');
subplot(122);imshow(bloodVessels);
title('Extracted Blood Vessels');