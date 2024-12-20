clc; clear all; close all hidden;
addpath("../")


Fs = 48000; % samples per second [Hz]

T = 1; %s (record time)
f0 = 0; %Hz
n1 = 1;
kmax = 4000;

[t, signal, fk, n0, phase] = frequencyGrid(Fs, T, f0, n1, kmax, true);

pause(T+1);


player = audioplayer(repmat(signal, 1, 3), Fs);
play(player);

recorder = audiorecorder(Fs, 16, 1);
record(recorder, T);

pause(T+1);

x_recorded = [getaudiodata(recorder)];

fft_results = fftshift(fft(x_recorded));
plot(Fs/(Fs*T)*(-Fs*T/2:Fs*T/2-1), 20*log(abs(fft_results)));
xlim([fk(0)-10, fk(kmax)+10])
xlabel('f [Hz]','FontSize',17);
ylabel('|H(f)| [dB]','FontSize',17);
title('FFT du signal enregistré en dB','FontSize',17);


figure;
plot(Fs/(Fs*T)*(-Fs*T/2:Fs*T/2-1), (abs(fft_results))) % only works for T=1s
xlim([fk(0)-10, fk(kmax)+10]);
xlabel('f [Hz]','FontSize',17);
ylabel('|H(f)|','FontSize',17);
title('FFT du signal enregistré','FontSize',17);

