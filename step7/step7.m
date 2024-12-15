clear; close all;
addpath("../step4/");

% --- noise parameters ---
SNRs = -50:5:0;
number_of_repetitions = 1;
% -------------------------

% ---------------------- define the constants -------------------------------
M = 16;
f0 = 8000; % [Hz]
delta_f = 400; % [Hz]
Fs = 48000; % [Hz]

% delta_f = 1/(2*T_min) =>
T = 10/(2*delta_f);

% relative delay duration :
relative_delay_duration = 0;

% message parameters, using a big parameter here alows us to use only 1 repetition as this is an ergodic process.
% but it is not always the most computationally efficient way to do it.
number_of_bytes = 100;
% ---------------------------------------------------------------------------


% ------------ generate the noiseless signal (runs only once)----------------
original_message = randi([0, 255], 1, number_of_bytes, "uint8"); 

number_of_chunks = length(original_message)*2;

% lenght of the signal + length of the delays
noiseless_signal_without_random_phase = zeros(1, T*Fs*relative_delay_duration*number_of_chunks ...
                                               + T*Fs*number_of_chunks ); 
noiseless_signal_with_random_phase = zeros(1, T*Fs*relative_delay_duration*number_of_chunks ...
                                            + T*Fs*number_of_chunks );

chunk_message_length = (T*Fs/2) + (T*Fs);
byte_message_length = 2*chunk_message_length;

for i = 1:length(original_message)
    byte_signal_without_random_phase = encode_byte(original_message(i), f0, delta_f, M, T, Fs, relative_delay_duration, 0);
    noiseless_signal_without_random_phase(((i-1)*byte_message_length + 1): i*byte_message_length) = byte_signal_without_random_phase;
    byte_signal_with_random_phase = encode_byte(original_message(i), f0, delta_f, M, T, Fs, relative_delay_duration, 1);
    noiseless_signal_with_random_phase(((i-1)*byte_message_length + 1): i*byte_message_length) = byte_signal_with_random_phase;
end

%normalize the signal
noiseless_signal_without_random_phase = noiseless_signal_without_random_phase/max(abs(noiseless_signal_without_random_phase));
noiseless_signal_with_random_phase = noiseless_signal_with_random_phase/max(abs(noiseless_signal_with_random_phase));
%---------------------------------------------------------------------------


% ---------------------- generate the noise (runs only once) and compute the signal power --------------------------
noise = randn(number_of_repetitions, length(noiseless_signal_without_random_phase));
signal_power = T/(2*log2(M));
% ------------------------------------------------------------------------------------------------------------------


function decoded_message = decode_message(signal, number_of_bytes, f0, delta_f, M, T, Fs, ...
                                         relative_delay_duration, non_coherent)
    decoded_message = zeros(1, number_of_bytes, "uint8");

    for i = 1:number_of_bytes
        chunk_1_signal = get_chunk(signal, 2*(i-1)+1, 0, T, Fs, 0, relative_delay_duration);
        chunk_2_signal = get_chunk(signal, 2*(i-1)+2, 0, T, Fs, 0, relative_delay_duration);
        decoded_message(i) = bitor(fsk_decode_1_chunk(chunk_1_signal, f0, delta_f, M, T, Fs, non_coherent),...
                                   bitshift(fsk_decode_1_chunk(chunk_2_signal, f0, delta_f, M, T, Fs, non_coherent), 4));
    end
end

% sanity check
if sum(decode_message(noiseless_signal_without_random_phase, number_of_bytes, f0, delta_f, M, T, Fs, relative_delay_duration, true) ~= original_message) ~= 0
    error("error in the decoding function, can't correctly decode the noiseless signal");
end

% test the effect of noise for each SNR

% for each SNR
%error_rates_per_SNR_non_coherent = zeros(1, length(SNRs));
%error_rates_per_SNR_coherent = zeros(1, length(SNRs));
% also with and without random phase
error_rates_per_SNR_non_coherent_random_phase = zeros(1, length(SNRs));
error_rates_per_SNR_coherent_random_phase = zeros(1, length(SNRs));

tic
c = parcluster;
parfor (k = 1:length(SNRs), c)
    % for each repetition
    noise_power = signal_power/(10^(SNRs(k)/10));
    %noisy_signal = noiseless_signal_without_random_phase + noise*sqrt(noise_power);
    noisy_signal_with_random_phase = noiseless_signal_with_random_phase + noise*sqrt(noise_power);

    %total_non_coherent_errors = 0;
    %total_coherent_errors = 0;
    total_non_coherent_errors_random_phase = 0;
    total_coherent_errors_random_phase = 0;
    for i = 1:number_of_repetitions
        % non-coherent decoding
        %decoded_message_non_coherent = decode_message(noisy_signal(i, :), number_of_bytes, f0, delta_f, M, T, Fs, relative_delay_duration, true);
        %total_non_coherent_errors = total_non_coherent_errors + sum(decoded_message_non_coherent ~= original_message);
        % coherent decoding
        %decoded_message_coherent = decode_message(noisy_signal(i, :), number_of_bytes, f0, delta_f, M, T, Fs, relative_delay_duration, false);
        %total_coherent_errors = total_coherent_errors + sum(decoded_message_coherent ~= original_message);

        % with random phase
        % non-coherent decoding
        decoded_message_non_coherent_random_phase = decode_message(noisy_signal_with_random_phase(i, :), number_of_bytes, f0, delta_f, M, T, Fs, relative_delay_duration, true);
        total_non_coherent_errors_random_phase = total_non_coherent_errors_random_phase + sum(decoded_message_non_coherent_random_phase ~= original_message);
        % coherent decoding
        decoded_message_coherent_random_phase = decode_message(noisy_signal_with_random_phase(i, :), number_of_bytes, f0, delta_f, M, T, Fs, relative_delay_duration, false);
        total_coherent_errors_random_phase = total_coherent_errors_random_phase + sum(decoded_message_coherent_random_phase ~= original_message);
    end
    %error_rates_per_SNR_non_coherent(k) = total_non_coherent_errors/(number_of_repetitions*number_of_bytes);
    %error_rates_per_SNR_coherent(k) = total_coherent_errors/(number_of_repetitions*number_of_bytes);
    error_rates_per_SNR_non_coherent_random_phase(k) = total_non_coherent_errors_random_phase/(number_of_repetitions*number_of_bytes);
    error_rates_per_SNR_coherent_random_phase(k) = total_coherent_errors_random_phase/(number_of_repetitions*number_of_bytes);
end
toc
hold on
%plot(SNRs, log10(error_rates_per_SNR_non_coherent), 'DisplayName', "non-coherent decoding")
%plot(SNRs, log10(error_rates_per_SNR_coherent), 'DisplayName', "coherent decoding")
plot(SNRs, log10(error_rates_per_SNR_non_coherent_random_phase), 'DisplayName', "non-coherent decoding with random phase")
plot(SNRs, log10(error_rates_per_SNR_coherent_random_phase), 'DisplayName', "coherent decoding with random phase")
legend()
title("Error rate as a function of the SNR")
xlabel("SNR [dB]")
ylabel("log10(Error rate)")
grid on