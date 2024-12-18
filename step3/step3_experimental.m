clc; clear all; close all hidden
addpath("../")

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
T = 1/freq_spacing; % freq_spacing = 1/T

% time vector
t = 0:1/Fs:T-1/Fs;
length(t)
signal = zeros(1, 2*Q);
for i = 1:Q
    signal = signal + cos(2*pi*f(i)*t - pi/4)*phase(i);
end

signal = signal/max(abs(signal));

plot(t, signal);
xlabel('t [s]','FontSize', 17);
ylabel('x(t)','fontsize', 17);

%pause(3) % pour avoir le temps de s'éloinger le l'ordinateur pour ne pas perturber la mesure


% --------- Emission et enregistrement du signal ----------
player = audioplayer(repmat(signal, 1, 10), Fs, 24);
pause(3);
play(player);



recorder = audiorecorder(Fs, 24, 1); 
record(recorder, T+0.5);

pause(T+1.5); % pour être sûr que la mesure est finie

x_recorded = [getaudiodata(recorder)];

x_recorded = x_recorded(48000/2 +1 :end);

Y_f = fft(x_recorded);
% ---------------------------------------------------------



% compensation de la phase
compensated_Y_f = [Y_f(1:Q).*phase'; Y_f(Q+1:2*Q).*phase(end:-1:1)'];
H_f = compensated_Y_f.*(2/T);

figure;
plot(Fs/Q*(-Q:(Q)-1), 20*log(abs(fftshift(compensated_Y_f))));
xlabel('f [Hz]','FontSize', 17);
ylabel('|Y(f)| [dB]','FontSize', 17); 

figure;
plot(Fs/Q*(-Q:(Q)-1), 20*log(abs(fftshift(H_f))));   
xlabel('f [Hz]','FontSize', 17);
ylabel('|H(f)| [dB]','FontSize', 17); 

y_t = ifft(Y_f);
h_t = ifft(H_f);

figure;
plot(t, y_t);
xlabel('t [s]','FontSize', 17);
ylabel('y(t)','FontSize', 17); 

figure;
plot(t, abs(h_t));
xlabel('t [s]','FontSize', 17);
ylabel('h(t)','FontSize', 17); 



