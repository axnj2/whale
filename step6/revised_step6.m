clc; clear all; close all;
addpath("../")

%parametres
Fs = 48000; % fréquence d'échantillonnage
Q = 4096; % nombre de fréquences échantillonées

%Signal to noise ratio
SNR = -44:4:-9; %dB
threshold_values = 0:0.01:2; % Define a range of threshold values
num_realization = 1000; % number of realizations

function [ht] = h(Fs)
    % h : impulse response of the system
    % calibrated for a sample rate of 48000 Hz
    arguments
        Fs double  % sample rate
    end
    delay = 0.001; % delay between transmission and reception in s

   
    alpha_r = 0.1;
    alpha_d = 0.9;
    d_m = 1; %m
    d_d = 0; %m
    v = 340; %m/s

    tau_d = d_d/v;
    tau_r = tau_d + 2*d_m/v;
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
    signal_conv_simu = signal_conv_simu/max(abs(signal_conv_simu));
end



function [reponse_impulsionnelle_simu] = calculate_impulse_response(received_OFDM_signal, Q, random_phase)
    % fft of the convoluted signal
    fft_signal_conv_simu = fft(received_OFDM_signal); % treats each column as one signal

    % compensation de la phase
    fft_signal_conv_phase_comp_simu = [fft_signal_conv_simu(1:Q,:).*random_phase'; fft_signal_conv_simu(Q+1:2*Q, :).*random_phase(end:-1:1)'];
    reponse_impulsionnelle_simu = ifft(fft_signal_conv_phase_comp_simu);
end

%received signal
[noiseless_received_signal, random_phase] = simu_OFDM_radar_send_receive_noiseless(Fs, Q);
P_signal = sum(noiseless_received_signal.^2) / length(noiseless_received_signal);

%find the real hits
[noiseless_impulse_response] = calculate_impulse_response(noiseless_received_signal,Q,random_phase);
real_hits_indices = find(abs(noiseless_impulse_response).^2 > 4);

%threshold
false_alarm_rates = zeros(length(SNR), length(threshold_values));
missed_detection_rates = zeros(length(SNR), length(threshold_values));


% Noise implementation (outside the loop) 
base_noise = randn(2 * Q, num_realization);

tic
for j_SNR = 1:length(SNR)
    P_noise = P_signal / (10^(SNR(j_SNR) / 10));
    noise = base_noise * sqrt(P_noise);
    % each column is a different realization of the noised signal
    noised_received_signal = noise + noiseless_received_signal; 
    noised_received_signal = noised_received_signal / max(max(abs(noised_received_signal)));

    [noised_impulse_response] = calculate_impulse_response(noised_received_signal, Q, random_phase);

    for i_thres = 1:length(threshold_values)
        threshold_value = threshold_values(i_thres);
        P_threshold = threshold_value^2;

        % Hit confirmation
        % returns the the row indices of the hits
        hits = abs(noised_impulse_response).^2 > P_threshold;
        [hits_indices, ~] = find(hits);

        % False alarm
        false_alarm_number = nnz(~ismember(hits_indices, real_hits_indices));
        false_alarm_rates(j_SNR, i_thres) = false_alarm_number / (2 * Q * num_realization);


        % Missed detection
        missed_detection_number = 0;
        for column_index = 1:num_realization
            hits_indices = find(hits(:, column_index));
            missed_detection_number = missed_detection_number  + nnz(~ismember(real_hits_indices, hits_indices));
        end

        missed_detection_rates(j_SNR, i_thres) = missed_detection_number / (2 * Q * num_realization);
    end
end
toc
colors = jet(length(SNR));

% Plot results
figure;
hold on;
for j_SNR = 1:length(SNR)
    plot(false_alarm_rates(j_SNR, :), missed_detection_rates(j_SNR, :), 'Color', colors(j_SNR, :), 'LineWidth', 2, 'DisplayName', sprintf('SNR = %d dB', SNR(j_SNR)));
end
xlabel('False Alarm Rate', 'FontSize', 17);
ylabel('Missed Detection Rate', 'FontSize', 17);
title('ROC Curve', 'FontSize', 19);
set(gca, 'FontSize', 15); % Set font size for axes
legend show;

