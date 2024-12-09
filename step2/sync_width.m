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
xlabel('t [s]');
ylabel('x(t)');

figure;
plot(t, signalRandomPhase);
xlabel('t [s]');
ylabel('x(t)'); 


figure;
plot(Fs/(Fs*T)*(-Fs*T/2:Fs*T/2-1), abs(fftshift(fft(signalNormalPhase))));
xlabel('f [Hz]');
ylabel('|X(f)|');
figure
plot(Fs/(Fs*T)*(-Fs*T/2:Fs*T/2-1), abs(fftshift(fft(signalRandomPhase))));
xlabel('f [Hz]');
ylabel('|X(f)|');