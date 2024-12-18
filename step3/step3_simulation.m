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
signal = zeros(1, 2*Q);
for i = 1:Q
    signal = signal + cos(2*pi*f(i)*t - pi/4)*phase(i);
end

signal = signal/max(abs(signal));

% ------- simulation de la réponse impulsionnelle ---------

function [ht] = h(Fs)
    % h : impulse response of the system
    % calibrated for a sample rate of 48000 Hz
    arguments
        Fs double  % sample rate
    end
    delay = 0.001; %s

    alpha_r = 0.1;
    alpha_d = 0.9;
    d_m = 1; %m
    d_d = 0.15; %m
    v = 340; %m/s

    tau_d = d_d/v;
    tau_r = tau_d + 2*d_m/v;
    t = 0:1/Fs:(delay + max(tau_d, tau_r) + 0.001);

    ht = alpha_r*rectangularPulse((t - tau_r - delay)*Fs ) + alpha_d*rectangularPulse((t - tau_d - delay )*Fs);
end


% convolute signal with h(t)
y_t_sim = conv(transpose(signal), h(Fs), 'same');

% received signal
figure
plot(t, y_t_sim);
xlabel('t [s]');
ylabel('y(t)'); % signal convoluted


% fft of the convoluted signal
Y_f_sim = fft(y_t_sim);

%plot of received signal fft
figure
plot(Fs/Q*(0:(Q)-1), 20*log(abs(fftshift(Y_f_sim(1:Q)))));
xlabel('f [Hz]');  
ylabel('|Y(f)| [dB]');

% phase compensation
compensated_Y_f_sim = [Y_f_sim(1:Q).*phase'; Y_f_sim(Q+1:2*Q).*phase(end:-1:1)'];
H_f_sim = compensated_Y_f_sim.*(2/T);


%plot of frequency response
figure;
plot(Fs/Q*(0:(Q)-1), 20*log(abs(fftshift(H_f_sim(1:Q)))));
xlabel('f [Hz]');
ylabel('|H(f)| [dB]'); 

y_t_com = ifft(compensated_Y_f_sim);
h_t_com = ifft(H_f_sim);

y_t_com_repeted= repmat(y_t_com, 1, 2);
h_t_com_repeted= repmat(h_t_com, 1, 2);


figure;
plot(t, abs(y_t_com_repeted(length(t)/2:3*length(t)/2-1)));
xlabel('t [s]');   
ylabel('y(t)'); 

%plot of impulse response
figure;
plot(t, abs(h_t_com_repeted(length(t)/2:3*length(t)/2-1)));
xlabel('t [s]');
ylabel('h(t)'); 


% ---------------------------------------------------------
