clc; clear; close all hidden;

% define the constants
M = 16;
f0 = 8000; % [Hz]
delta_f = 400; % [Hz]
Fs = 48000; % [Hz]

%lengh of the message
T = 1; % [s]

% listen for the incomming signal
recorder = audiorecorder(Fs,24,1);
record(recorder,T+3);

pause(1);

%store recorded message
recorded_message = [getaudiodata(recorder)];
size(recorded_message)

%decode message
fsk_decode_1_period([2;1],f0, delta_f, M, T, Fs); %recorded message transposed to have the good dimensions (colonnes)


