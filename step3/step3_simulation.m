clc; clear all; close all hidden
addpath("../")

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

figure
plot(t, y_t_sim);
xlabel('t [s]');
ylabel('y(t)'); % signal convoluted


% fft of the convoluted signal
Y_f_sim = fft(y_t_sim);

figure
plot(Fs/Q*(0:(Q)-1), 20*log(abs(fftshift(Y_f_sim(1:Q)))));
xlabel('f [Hz]');  
ylabel('|Y(f)|');

% compensation de la phase
compensated_Y_f_sim = [Y_f_sim(1:Q).*phase'; Y_f_sim(Q+1:2*Q).*phase(end:-1:1)'];
H_f_sim = compensated_Y_f_sim.*(2/T);

figure;
plot(Fs/Q*(0:(Q)-1), 20*log(abs(fftshift(H_f_sim(1:Q)))));
xlabel('f [Hz]');
ylabel('|H(f)|'); % réponse en fréquence

y_t_com = ifft(compensated_Y_f_sim);
h_t_com = ifft(H_f_sim);

y_t_com_repeted= repmat(y_t_com, 1, 2);
h_t_com_repeted= repmat(h_t_com, 1, 2);

%[hits, threshold] = CFAR(h_t_com, 10, 2,60);
figure;
plot(t, y_t_com_repeted(length(t)/2:3*length(t)/2-1));
xlabel('t [s]');   
ylabel('y(t)'); % réponse impulsionnelle
figure;
plot(t, abs(h_t_com_repeted(length(t)/2:3*length(t)/2-1)));
xlabel('t [s]');
ylabel('h(t)'); % réponse impulsionnelle


% ---------------------------------------------------------
