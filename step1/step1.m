clc; clear all; close all hidden;

fp = 2000; %Hz
Fs = 48000; % samples per second [Hz]
samples = 1024;
Tf = samples/Fs; %s
T = 1/Fs;
Tp = 0.01; % length of the pulse [s]

function x = g(t, fp, Tp)
    x=0;
    if t < Tp
        x = sin(2*pi*fp*t);
    end
end

% avec les param de l'énoncé
t = linspace(0, Tf, samples);
x = zeros(size(t));
for k = 1:length(t)
    x(k) = g(t(k), fp, Tp);
end

% fft avant de l'émettre et enregistrer
figure;
plot(Fs/samples*(-samples/2:samples/2-1), abs(fftshift(fft(x))))
figure;
plot(t, x);


player = audioplayer(repmat(x, 1, 50), Fs);
play(player);

recorder = audiorecorder(Fs, 24, 1);
record(recorder, Tf);

pause(Tf+1);

x_recorded = [getaudiodata(recorder)];
samples_recorded = length(x_recorded);

%plot(t, x_recorded');

fft_results = fft(x_recorded);
centered_fft_results = fftshift(fft_results); 

figure;
plot(Fs/samples_recorded*(-samples_recorded/2:samples_recorded/2-1), abs(centered_fft_results));



% avec un signal plus court
t = linspace(0, Tf, samples);
x = zeros(size(t));
for k = 1:length(t)
    x(k) = g(t(k), fp, 0.001);
end

figure;
plot(Fs/samples*(-samples/2:samples/2-1), abs(fftshift(fft(x))))