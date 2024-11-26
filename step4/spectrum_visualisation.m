clc; clear; close all;

% Load the data and parameters
signal = audioread("step_4_output.wav");
load("parameters.mat", "f0", "delta_f", "M", "T", "Fs");

% sliding window parameters
%window_size = floor(window_time*Fs);
%window_size = 100;

visualise_signal_spectrum(T, Fs, signal);





