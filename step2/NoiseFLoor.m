clc; clear all; close all hidden;

Fs = 48000; % samples per second [Hz]
Tf = 1; %s (record time)

recorder = audiorecorder(Fs, 16, 1);
record(recorder, Tf);

pause(Tf+0.2);

result = getaudiodata(recorder);
samples = length(result)
fft_results = fftshift(fft(result));

plot (Fs/samples*(-samples/2:samples/2-1), 20*log(abs(fft_results)))
figure;
plot (Fs/samples*(-samples/2:samples/2-1), abs(fft_results))

% noise very low after 2000Hz