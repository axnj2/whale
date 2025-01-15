clc; clear; close all;

% Load the data and parameters

%%D'abord run le fichier step4_sender.m
signal = audioread("step_4_output.wav"); %D'abord run le fichier step4_sender.m
load("parameters.mat", "f0", "delta_f", "M", "T", "Fs");

% sliding window parameters
%window_size = floor(window_time*Fs);
%window_size = 100;

visualise_signal_spectrum(T, Fs, signal, true);






