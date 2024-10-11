clc; clear all; close all hidden;

Fs = 48000; % samples per second [Hz]

T = 1; %s (record time)
f0 = 1000; %Hz
n1 = 50;
kmax = 12;

[t, signal, fk, n0] = frequencyGrid(Fs, T, f0, n1, kmax);

pause(T+1);


player = audioplayer(repmat(signal, 1, 3), Fs);
play(player);

recorder = audiorecorder(Fs, 16, 1);
record(recorder, T);

pause(T+1);

x_recorded = [getaudiodata(recorder)];

fft_results = fftshift(fft(x_recorded));
plot(fk(0):fk(kmax), abs(fft_results(24001+n0:24001 + n0+ kmax*n1))); % only works for T=1s
xlim([fk(0)-10, fk(kmax)+10]);