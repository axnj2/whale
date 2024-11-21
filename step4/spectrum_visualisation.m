clc; clear; close all;

% Load the data and parameters
signal = audioread("step_4_output.wav");
load("parameters.mat", "f0", "delta_f", "M", "T", "Fs");

% sliding window parameters
window_size = T*Fs;
number_of_windows = floor(length(signal)/window_size);

% Compute the spectrum for each window
spectrum = zeros(ceil(window_size/2)+1, number_of_windows);
for i = 1:number_of_windows
    window = signal((i-1)*window_size+1:i*window_size);
    fft_window = fft(window);
    spectrum(:, i) = abs(fft_window(1:window_size/2+1));
end

figure;
plot(signal);

% show the spectrum
figure;
imagesc(spectrum);



