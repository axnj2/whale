clc; clear all; close all hidden;

fp = 8000; %Hz
Tp = 3; %s
Fs = 48000; % samples per second [Hz]
samples = Fs*Tp;
T = 1/Fs;

t = linspace(0, Tp, samples);
x = cos(2*pi*fp*t);

player = audioplayer(x, Fs);
play(player);

recorder = audiorecorder(Fs, 16, 1);
record(recorder, Tp);

pause(Tp);

x_recorded = [getaudiodata(recorder)];
samples_recorded = length(x_recorded);

t = linspace(0, Tp, length(x_recorded));

%plot(t, x_recorded');

fft_results = fft(x_recorded);
centered_fft_results = fftshift(fft_results); 

figure;
plot(Fs/samples_recorded*(-samples_recorded/2:samples_recorded/2-1), abs(centered_fft_results));

