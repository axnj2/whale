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
    signal = signal + cos(2*pi*f(i)*t - pi/4)*phase(i);
end

signal = signal/max(abs(signal));



%pause(3) % pour avoir le temps de s'éloinger le l'ordinateur pour ne pas perturber la mesure


% --------- Emission et enregistrement du signal ----------
player = audioplayer(repmat(signal, 1, 10), Fs, 24, 1); % 1 is the ID of the macbook speaker
play(player);

recorder = audiorecorder(Fs, 24, 1, 0); % 0 is the ID of the macbook microphone
record(recorder, T);

pause(T+1); % pour être sûr que la mesure est finie

x_recorded = [getaudiodata(recorder)];

raw_fft_results = fft(x_recorded);
% ---------------------------------------------------------



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

% ------- simulation de la réponse impulsionnelle ---------

function [ht] = h(Fs)
    % h : impulse response of the system
    % calibrated for a sample rate of 48000 Hz
    arguments
        Fs double  % sample rate
    end
    delay = 0.001; %s

    alpha_r = 0.4;
    alpha_d = 0.5;
    d_m = 0.15; %m
    d_d = 0.05; %m
    v = 340; %m/s

    tau_r = 2*d_m/v;
    tau_d = d_d/v;

    t = 0:1/Fs:(delay + max(tau_d, tau_r) + 0.001);

    ht = alpha_r*rectangularPulse((t - tau_r - delay)*Fs ) + alpha_d*rectangularPulse((t - tau_d - delay )*Fs);
end

% show h(t)
figure
plot(h(Fs));

% convolute signal with h(t)
signal_conv_simu = conv(transpose(signal), h(Fs), 'same');
figure
plot(t, signal_conv_simu);

% fft of the convoluted signal
fft_signal_conv_simu = fft(signal_conv_simu);
figure
plot(Fs/Q*(0:(Q)-1), abs(fftshift(fft_signal_conv_simu(1:Q))));

% compensation de la phase
fft_signal_conv_phase_comp_simu = [fft_signal_conv_simu(1:Q).*phase'; fft_signal_conv_simu(Q+1:2*Q).*phase(end:-1:1)'];

reponse_impulsionnelle_simu = ifft(fft_signal_conv_phase_comp_simu);
figure;
reponse_impulsionnelle_simu_repeted = repmat(reponse_impulsionnelle_simu, 1, 2);
plot(t, reponse_impulsionnelle_simu_repeted(length(t)/2:3*length(t)/2-1));


% ---------------------------------------------------------