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
num_realisations = 10;
bias_samples = 0.1:0.1:1;
SNR_samples = -40:5:20;



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

% real hits
real_hits_indices = [284, 7918, 7920];

Results_table = zeros(length(SNR_samples), length(bias_samples), 2);

for i_SNR = 1:length(SNR_samples)
    for i_bias = 1:length(bias_samples)
        num_false_alarms = zeros(1,num_realisations);
        num_missed_dectections = zeros(1,num_realisations);
        for i = 1:num_realisations
            [reponse_impulsionnelle_simu, t] = simu_canal_OFDM_radar(Fs, Q, SNR_samples(i_SNR));

            [hits_indices] = detect_hits(reponse_impulsionnelle_simu, 25, 5, bias_samples(i_bias));
        
            acc_detect = find(hits_indices==real_hits_indices(1) | hits_indices==real_hits_indices(2) | hits_indices==real_hits_indices(3));
            num_acc_detect = length(acc_detect);
            number_missed_detect = 2-num_acc_detect;

            false_alarms = hits_indices(not(hits_indices==real_hits_indices(1) | hits_indices==real_hits_indices(2)| hits_indices==real_hits_indices(3)));
            num_false_alarm = length(false_alarms);
            num_false_alarms(i) = num_false_alarm;
            num_missed_dectections(i) = number_missed_detect;
        end
        sum(num_false_alarms)
        sum(num_missed_dectections)
    end
end
%{
% plot
figure
plot(t, abs(reponse_impulsionnelle_simu), t, threshold)
hold on
scatter(t, hits, "filled", "red")
%}
