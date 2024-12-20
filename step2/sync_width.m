clc; clear all; close all hidden;
%add("../")

Fs = 48000; % samples per second [Hz]

T = 1; %s (record time)
f0 = 2000; %Hz
n1 = 1;
kmax = 1000;

[t, signalNormalPhase] = frequencyGrid(Fs, T, f0, n1, kmax, false);
[t, signalRandomPhase] = frequencyGrid(Fs, T, f0, n1, kmax, true);

figure;
plot(t, signalNormalPhase);
xlabel('t [s]', 'FontSize', 17);
ylabel('x(t)', 'FontSize', 17);
title('Signal sans phase aléatoire', 'FontSize', 17);

figure;
plot(t, signalRandomPhase);
xlabel('t [s]', 'FontSize', 17);
ylabel('x(t)', 'FontSize', 17); 
title('Signal avec phase aléatoire', 'FontSize', 17);


figure;
plot(Fs/(Fs*T)*(-Fs*T/2:Fs*T/2-1), abs(fftshift(fft(signalNormalPhase))));
xlabel('f [Hz]', 'FontSize', 17);
ylabel('|X(f)|', 'FontSize', 17);
title('FFT du signal sans phase aléatoire', 'FontSize', 17);

figure
plot(Fs/(Fs*T)*(-Fs*T/2:Fs*T/2-1), abs(fftshift(fft(signalRandomPhase))));
xlabel('f [Hz]', 'FontSize', 17);
ylabel('|X(f)|', 'FontSize', 17);
title('FFT du signal avec phase aléatoire', 'FontSize', 17);
