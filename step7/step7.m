clear;
addpath("../step4/");
tic
% --- noise parameters ---
EbN0s = -18:2:10;
number_of_repetitions = 10;
% -------------------------

% ---------------------- define the constants -------------------------------
M = 16;
f0 = 8000; % [Hz]
delta_f = 400; % [Hz]
Fs = 48000; % [Hz]

% delta_f = 1/(2*T_min) =>
T = 1/(delta_f);

relative_delay_duration = 0;

% message parameters, using a big parameter here alows us to use only 1 repetition as this is an ergodic process.
% but it is not always the most computationally efficient way to do it.
number_of_symbols = 5000;
% ---------------------------------------------------------------------------





% ------------ generate the noiseless signal (runs only once)----------------
chunk_values = randi([0, M-1], 1, number_of_symbols, "uint16");  % max M = 2^16 = 65536 (can be changed)

number_of_chunks = length(chunk_values);

% lenght of the signal + length of the delays
noiseless_signal_without_random_phase = zeros(1, T*Fs*relative_delay_duration*number_of_chunks ...
                                               + T*Fs*number_of_chunks ); 
noiseless_signal_with_random_phase = zeros(1, T*Fs*relative_delay_duration*number_of_chunks ...
                                            + T*Fs*number_of_chunks );

chunk_message_length = (T*Fs*relative_delay_duration) + (T*Fs);

% encode the message
for i = 1:length(chunk_values)
    % without random phase
    % byte_signal_without_random_phase = fsk_gen_1_period(f0, delta_f, M, T, Fs, chunk_values(i), false);
    % noiseless_signal_without_random_phase(((i-1)*chunk_message_length + 1): i*chunk_message_length) = byte_signal_without_random_phase;
    % same thing but with random phase
    [~, byte_signal_with_random_phase] = fsk_gen_1_period(f0, delta_f, M, T, Fs, chunk_values(i), true);
    noiseless_signal_with_random_phase(((i-1)*chunk_message_length + 1): i*chunk_message_length) = byte_signal_with_random_phase;
end

%normalize the signals
% noiseless_signal_without_random_phase = noiseless_signal_without_random_phase/max(abs(noiseless_signal_without_random_phase));
noiseless_signal_with_random_phase = noiseless_signal_with_random_phase/max(abs(noiseless_signal_with_random_phase));
%---------------------------------------------------------------------------


% ---------------------- generate the noise (runs only once) and compute the signal power --------------------------
noise = randn(number_of_repetitions, length(noiseless_signal_without_random_phase));
power_per_bit = T/(2*log2(M));
% ------------------------------------------------------------------------------------------------------------------


function decoded_message = decode_message(signal, number_of_symbols, f0, delta_f, M, T, Fs, ...
                                         relative_delay_duration, non_coherent)
    chunks_value = zeros(1, number_of_symbols, "uint16");
    for i = 1:number_of_symbols
        chunks_value(i) = fsk_decode_1_chunk(get_chunk(signal, i, 0, T, Fs, 0, relative_delay_duration),...
                                            f0, delta_f, M, T, Fs, non_coherent);
    end
    decoded_message = chunks_value;
end

% sanity check
if sum(decode_message(noiseless_signal_with_random_phase, number_of_symbols, f0, delta_f, M, T, Fs, relative_delay_duration, true) ~= chunk_values) ~= 0
    error("error in the decoding function, can't correctly decode the noiseless signal");
end

% test the effect of noise for each SNR

% for each SNR
%error_rates_per_SNR_non_coherent = zeros(1, length(SNRs));
%error_rates_per_SNR_coherent = zeros(1, length(SNRs));
% also with and without random phase
bit_error_rates_non_coherent_random_phase = zeros(1, length(EbN0s));
bit_error_rates_coherent_random_phase = zeros(1, length(EbN0s));

display("intialization time : ")
toc
tic
c = parcluster;
parfor (k = 1:length(EbN0s), c)
    % for each repetition
    N0 = power_per_bit/(10^(EbN0s(k)/10));
    noise_power = N0*Fs/2;
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
        decoded_message_non_coherent_random_phase = decode_message(noisy_signal_with_random_phase(i, :), number_of_symbols, f0, delta_f, M, T, Fs, relative_delay_duration, true);
        total_non_coherent_errors_random_phase = total_non_coherent_errors_random_phase + sum(decoded_message_non_coherent_random_phase ~= chunk_values);
        % coherent decoding
        decoded_message_coherent_random_phase = decode_message(noisy_signal_with_random_phase(i, :), number_of_symbols, f0, delta_f, M, T, Fs, relative_delay_duration, false);
        total_coherent_errors_random_phase = total_coherent_errors_random_phase + sum(decoded_message_coherent_random_phase ~= chunk_values);
    end
    %error_rates_per_SNR_non_coherent(k) = total_non_coherent_errors/(number_of_repetitions*number_of_bytes);
    %error_rates_per_SNR_coherent(k) = total_coherent_errors/(number_of_repetitions*number_of_bytes);
    bit_error_rates_non_coherent_random_phase(k) = total_non_coherent_errors_random_phase/(number_of_repetitions*number_of_symbols);
    bit_error_rates_coherent_random_phase(k) = total_coherent_errors_random_phase/(number_of_repetitions*number_of_symbols);
end
disp("simulation time : ")
toc


% theoritical curves with ber = berawgn(EbNo,'fsk',M,coherence)

bit_error_rates_non_coherent_theoritical = berawgn(EbN0s, 'fsk', M, 'noncoherent');


hold on
%plot(EbN0s, log10(error_rates_per_SNR_non_coherent), 'DisplayName', "non-coherent decoding")
%plot(EbN0s, log10(error_rates_per_SNR_coherent), 'DisplayName', "coherent decoding")
% semilogy(EbN0s, (bit_error_rates_non_coherent_random_phase), 'DisplayName', "non-coherent decoding with random phase")
% semilogy(EbN0s, (bit_error_rates_coherent_random_phase), 'DisplayName', "coherent decoding with random phase")
% semilogy(EbN0s, (bit_error_rates_non_coherent_theoritical), 'DisplayName', "theoritical coherent decoding")
figure
semilogy(EbN0s, [bit_error_rates_non_coherent_random_phase; bit_error_rates_coherent_random_phase; bit_error_rates_non_coherent_theoritical], '-o')
legend("non-coherent decoding with random phase", "coherent decoding with random phase", "theoritical non-coherent decoding")
title("Error rate as a function of the ratio Eb/N0")
xlabel("Eb/N0 [dB]")
ylabel("log10(Error rate)")
grid on