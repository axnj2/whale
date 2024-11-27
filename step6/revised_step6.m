clear all; close all;
addpath("../")

%parametres
Fs = 48000; % fréquence d'échantillonnage
Q = 4096; % nombre de fréquences échantillonées

%Signal to noise ratio
SNR_values = -20:5:20; %dB

bias_values = 0.01:0.01:1; %100 bias values for each SNR



function [ht] = h(Fs)
    % h : impulse response of the system
    % calibrated for a sample rate of 48000 Hz
    arguments
        Fs double  % sample rate
    end
    delay = 0.001; % delay between transmission and reception in s

    alpha_r = 0.4;
    alpha_d = 0.5;
    d_m = 2; %m
    d_d = 0.05; %m
    v = 340; %m/s

    tau_r = 2*d_m/v;
    tau_d = d_d/v;

    %time vector where 0.001 is a safety margin
    t = 0:1/Fs:(delay + max(tau_d, tau_r) + 0.001);

    ht = alpha_r*rectangularPulse((t - tau_r - delay)*Fs ) + alpha_d*rectangularPulse((t - tau_d - delay )*Fs);
end


function [signal_conv_simu, random_phase] = simu_OFDM_radar_send_receive_noiseless(Fs, Q)
    % espacement entre les fréquences : 
    freq_spacing = Fs/(2*Q); % précédemment n1
    k = 0:Q-1; % indices des fréquences

    % fréquency vector
    f = k*freq_spacing; % fréquences

    % random phase
    random_phase = 2*randi([0,1], 1, Q) - 1;

    % max time
    T = 1/freq_spacing;  % freq_spacing = 1/T

    % time vector
    t = 0:1/Fs:T-1/Fs;
    signal = zeros(1, 2*Q);
    for i = 1:Q
        signal = signal + cos(2*pi*f(i)*t - pi/4)*random_phase(i);
    end
    %normalize signal
    signal = signal/max(abs(signal));


    % convolute signal with h(t)
    signal_conv_simu = conv(transpose(signal), h(Fs), 'same');
end



function [reponse_impulsionnelle_simu] = calculate_impulse_response(received_OFDM_signal, Q, random_phase)
    % fft of the convoluted signal
    fft_signal_conv_simu = fft(received_OFDM_signal);

    % compensation de la phase
    fft_signal_conv_phase_comp_simu = [fft_signal_conv_simu(1:Q).*random_phase'; fft_signal_conv_simu(Q+1:2*Q).*random_phase(end:-1:1)'];
    
    reponse_impulsionnelle_simu = ifft(fft_signal_conv_phase_comp_simu);
end

%received signal

[noiseless_received_signal, random_phase] = simu_OFDM_radar_send_receive_noiseless(Fs, Q);

%impluse response
[impluse_response] = calculate_impulse_response(noiseless_received_signal,Q,random_phase);

t = 0:1/Fs:(2*Q/Fs)-1/Fs;
figure
plot(t,impluse_response);


for i = 1:length(SNR_values)
    SNR = SNR_values(i);
    P_signal = sum(noiseless_received_signal.^2)/length(noiseless_received_signal);
    % SNR = 10 log_10(P_signal/P_noise) => P_noise = P_signal/10^(SNR/10)
    P_noise = P_signal/10^(SNR/10);  
    for j = 1:length(bias_values)
        noise = randn(1,2*Q)*sqrt(P_noise);
        
    end

end    
