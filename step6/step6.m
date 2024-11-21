clear; close all;
addpath("../")

function [ht] = h(Fs)
    % h : impulse response of the system
    % calibrated for a sample rate of 48000 Hz
    arguments
        Fs double  % sample rate
    end
    delay = 0.001; %s

    alpha_r = 0.4;
    alpha_d = 0.5;
    d_m = 2; %m
    d_d = 0.05; %m
    v = 340; %m/s

    tau_r = 2*d_m/v;
    tau_d = d_d/v;

    t = 0:1/Fs:(delay + max(tau_d, tau_r) + 0.001);

    ht = alpha_r*rectangularPulse((t - tau_r - delay)*Fs ) + alpha_d*rectangularPulse((t - tau_d - delay )*Fs);
end

% Paramètres
SNR = -20; % signal to noise ratio [dB]
bias = 0.5;
% grille de fréquences
% on choisit le temps d'enregistrement par rapport au nombre de fréquences échantillonées
Fs = 48000; % fréquence d'échantillonnage
Q = 4096; % nombre de fréquences échantillonées

% statistical analysis
num_realisations = 20;
bias_samples = 0.1:0.1:1;
SNR_samples = -20:10:20;



function [reponse_impulsionnelle_simu, t] = simu_canal_OFDM_radar(Fs, Q, SNR)
    % espacement entre les fréquences : 
    freq_spacing = Fs/(2*Q); % précédemment n1
    k = 0:Q-1; % indices des fréquences

    % fréquency vector
    f = k*freq_spacing; % fréquences

    % random phase
    phase = 2*randi([0,1], 1, Q) - 1;

    % max time
    T = 1/freq_spacing;  % freq_spacing = 1/T

    % time vector
    t = 0:1/Fs:T-1/Fs;
    signal = zeros(1, 2*Q);
    for i = 1:Q
        signal = signal + cos(2*pi*f(i)*t - pi/4)*phase(i);
    end
    %normalize signal
    signal = signal/max(abs(signal));
    P_signal = sum(signal.^2)/length(signal);

    % add noize
    % SNR = 20 log_10(P_signal/P_noise) => P_noise = P_signal/10^(SNR/20)

    signal = signal + sqrt(P_signal/(10^(SNR/20)))*randn(1, 2*Q); % add a gaussian noise of mean 0 and standard deviation sqrt(P_signal/(10^(SNR/20)))
    %P_signal
    %sqrt(P_signal/(10^(SNR/20)))

    signal = signal/max(abs(signal));


    % convolute signal with h(t)
    signal_conv_simu = conv(transpose(signal), h(Fs), 'same');
    
    % fft of the convoluted signal
    fft_signal_conv_simu = fft(signal_conv_simu);

    % compensation de la phase
    fft_signal_conv_phase_comp_simu = [fft_signal_conv_simu(1:Q).*phase'; fft_signal_conv_simu(Q+1:2*Q).*phase(end:-1:1)'];
    
    reponse_impulsionnelle_simu = ifft(fft_signal_conv_phase_comp_simu);
    
end

function [hits_indices] = detect_hits(reponse_impulsionnelle_simu, numRefCells, numGapCells, bias)
    [hits, ~] = CFAR(abs(reponse_impulsionnelle_simu), numRefCells, numGapCells, bias);
    hits_indices = find(hits);

    % remove consecutive hits
    keep_indices = ones(size(hits_indices), "logical");
    for k = 1:length(hits_indices)
        if find(hits_indices(k)+1==hits_indices)
            keep_indices(k) = false;
        elseif find(hits_indices(k)+2==hits_indices)
            keep_indices(k) = false;
        end 
    end
    hits_indices = hits_indices(keep_indices);

end

tic
% real hits
real_hits_indices = [284, 7918, 7920];

Results_table = zeros(length(SNR_samples), length(bias_samples), 2);

for i_SNR = 1:length(SNR_samples)
    for i_bias = 1:length(bias_samples)
        false_alarms_rates = zeros(1,num_realisations);
        missed_dectections_rates = zeros(1,num_realisations);
        for i = 1:num_realisations
            [reponse_impulsionnelle_simu, t] = simu_canal_OFDM_radar(Fs, Q, SNR_samples(i_SNR));

            [hits_indices] = detect_hits(reponse_impulsionnelle_simu, 25, 5, bias_samples(i_bias));
        
            acc_detect = find(hits_indices==real_hits_indices(1) | hits_indices==real_hits_indices(2) | hits_indices==real_hits_indices(3));
            num_acc_detect = length(acc_detect);
            number_missed_detect = 2-num_acc_detect;
            missed_detection_rate = number_missed_detect/2;

            false_alarms = hits_indices(not(hits_indices==real_hits_indices(1) | hits_indices==real_hits_indices(2)| hits_indices==real_hits_indices(3)));
            false_alarm_rate = length(false_alarms)/(2*Q); % alarm rate per sample

            false_alarms_rates(i) = false_alarm_rate;
            missed_dectections_rates(i) = missed_detection_rate;
        end
        Results_table(i_SNR, i_bias, 1) = mean(false_alarms_rates);
        Results_table(i_SNR, i_bias, 2) = mean(missed_dectections_rates);
    end
end
toc

figure
hold on
for i = 1:length(SNR_samples)
    plot(  Results_table(i,:,2), Results_table(i, :, 1),  'DisplayName', sprintf("SNR = %d dB", SNR_samples(i)))
end
xlabel("Missed detection rate")
ylabel("False alarm rate")

%{
% plot
figure
plot(t, abs(reponse_impulsionnelle_simu), t, threshold)
hold on
scatter(t, hits, "filled", "red")
%}
