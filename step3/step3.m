clc; clear all; close all hidden

% grille de fréquences
% on choisit le temps d'enregistrement par rapport au nombre de fréquences échantillonées

% Paramètres
Fs = 48000; % fréquence d'échantillonnage
Q = 4096; % nombre de fréquences échantillonées


% espacement entre les fréquences : 
freq_spacing = Fs/(2*Q); % précédemment n1
k = 0:Q-1; % indices des fréquences

% fréquency vector
f = k*freq_spacing; % fréquences

% random phase
phase = 2*randi([0,1], 1, Q) - 1;

% max time
T = 1/freq_spacing  % freq_spacing = 1/T

% time vector
t = 0:1/Fs:T-1/Fs;
length(t)
signal = zeros(1, 2*Q);
for i = 1:Q
    signal = signal + cos(2*pi*f(i)*t)*phase(i);
end

signal = signal/max(abs(signal));

pause(3) % pour avoir le temps de s'éloinger le l'ordinateur pour ne pas perturber la mesure

player = audioplayer(repmat(signal, 1, 10), Fs, 24, 1); % 1 is the ID of the macbook speaker
play(player);

recorder = audiorecorder(Fs, 24, 1, 0); % 0 is the ID of the macbook microphone
record(recorder, T);

pause(T+1); % pour être sûr que la mesure est finie

x_recorded = [getaudiodata(recorder)];

raw_fft_results = fft(x_recorded);

figure;
plot(Fs/Q*(0:(Q)-1), abs(raw_fft_results(1:Q)));

figure;
% compensation de la phase
fft_results = [raw_fft_results(1:Q).*phase'; raw_fft_results(Q+1:2*Q).*phase(end:-1:1)'];
plot(Fs/Q*(-Q:(Q)-1), abs(fftshift(fft_results)));


reponse_impulsionnelle = ifft(fft_results);
figure;
plot(t, reponse_impulsionnelle);


% feedback : on peut aussi le faire en simulation pour valider que le code fonctionne correctement.

