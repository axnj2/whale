clear;
addpath("../step4/");
tic
% --- noise parameters ---
EbN0s = 2:1:8;
number_of_repetitions = 500;
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
number_of_symbols = 200;
% ---------------------------------------------------------------------------

compute_coherent = true;




% ------------ generate the noiseless signal (runs only once)----------------
chunk_values = randi([0, M-1], 1, number_of_symbols, "uint16");  % max M = 2^16 = 65536 (can be changed)

number_of_chunks = length(chunk_values);

% lenght of the signal + length of the delays
noiseless_signal = zeros(1, T*Fs*relative_delay_duration*number_of_chunks ...
                                            + T*Fs*number_of_chunks );

chunk_message_length = (T*Fs*relative_delay_duration) + (T*Fs);

% encode the message
for i = 1:length(chunk_values)

    [~, byte_signal] = fsk_gen_1_period(f0, delta_f, M, T, Fs, chunk_values(i), true);
    noiseless_signal(((i-1)*chunk_message_length + 1): i*chunk_message_length) = byte_signal;
end

%normalize the signals
noiseless_signal = noiseless_signal/max(abs(noiseless_signal));
%---------------------------------------------------------------------------


% ---------------------- generate the noise (runs only once) and compute the signal power --------------------------
%noise = randn(number_of_repetitions, length(noiseless_signal_without));
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
if sum(decode_message(noiseless_signal, number_of_symbols, f0, delta_f, M, T, Fs, relative_delay_duration, true) ~= chunk_values) ~= 0
    error("error in the decoding function, can't correctly decode the noiseless signal");
end

% test the effect of noise for each SNR

% for each SNR
symbol_error_rates_non_coherent = zeros(1, length(EbN0s));
if compute_coherent
    symbol_error_rates_coherent = zeros(1, length(EbN0s));
end

display("intialization time : ")
toc
tic
c = parcluster;
parfor (k = 1:length(EbN0s), c)
    % for each repetition
    N0 = power_per_bit/(10^(EbN0s(k)/10));
    noise_power = N0*Fs/2;
    noisy_signal = zeros(1, length(noiseless_signal));

    total_non_coherent_errors = 0;
    total_coherent_errors = 0;
    for i = 1:number_of_repetitions
        noisy_signal = noiseless_signal + randn(1, length(noiseless_signal))*sqrt(noise_power);

        
        % non-coherent decoding
        decoded_message_non_coherent = decode_message(noisy_signal, number_of_symbols, f0, delta_f, M, T, Fs, relative_delay_duration, true);
        total_non_coherent_errors = total_non_coherent_errors + sum(decoded_message_non_coherent ~= chunk_values);
        if compute_coherent
            % coherent decoding
            decoded_message_coherent = decode_message(noisy_signal, number_of_symbols, f0, delta_f, M, T, Fs, relative_delay_duration, false);
            total_coherent_errors = total_coherent_errors + sum(decoded_message_coherent ~= chunk_values);
        end
    end
    symbol_error_rates_non_coherent(k) = total_non_coherent_errors/(number_of_repetitions*number_of_symbols);
    if compute_coherent
        symbol_error_rates_coherent(k) = total_coherent_errors/(number_of_repetitions*number_of_symbols);
    end
end
disp("simulation time : ")
toc


% theoritical curves with ber = berawgn(EbNo,'fsk',M,coherence)
[~, symbol_error_rates_non_coherent_theoritical] = berawgn(EbN0s, 'fsk', M, 'noncoherent');



figure
if compute_coherent
    semilogy(EbN0s, [symbol_error_rates_non_coherent;  symbol_error_rates_non_coherent_theoritical; symbol_error_rates_coherent], '-o')
    legend("non-coherent decoding with random phase", "coherent decoding with random phase", "theoritical non-coherent decoding")
else
    semilogy(EbN0s, [symbol_error_rates_non_coherent; symbol_error_rates_non_coherent_theoritical], '-o')
    legend("non-coherent decoding with random phase", "theoritical non-coherent decoding")
end
title("Error rate as a function of the ratio Eb/N0")
xlabel("Eb/N0 [dB]")
ylabel("Symbol error rate")

pbaspect([1 1.5 1])

ax = gca;
ax.FontSize = 20;
h = get(ax,'children');
set(h, 'LineWidth',1.5)
grid on