clc; clear all; close all hidden;

fp = 300; %Hz
Tp = 3; %s
Fs = 48000; % samples per second [Hz]
samples = Fs*Tp;
T = 1/Fs;

t = linspace(0, Tp, samples);
x = cos(2*pi*fp*t);

x_noised = x; %+ randn(1, samples);

fft_results = fft(x_noised);
centered_fft_restuls = fftshift(fft_results);

%plot(t, x_noised);
%figure;
%plot(Fs/samples*(-samples/2:samples/2-1), abs(centered_fft_restuls));



