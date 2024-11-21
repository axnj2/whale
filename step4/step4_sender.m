clc; clear; close all hidden;

% define the constants
M = 16;
f0 = 8000; % [Hz]
delta_f = 400; % [Hz]
Fs = 48000; % [Hz]

% delta_f = 1/(2*T) =>
T = 10/(2*delta_f);

message = 'hello sound communication';

% switch between playing sound and saving to file for testing
play_sound = false;

function [signal] = encode_byte(byte, f0, delta_f, M, T, Fs)
    % we first select the 4 least significant bits with mod(a, 16) and then the 4 most significant bits with bitshift(a, -4)
    arguments
        byte uint8
        f0 double
        delta_f double
        M double
        T double
        Fs double
    end

    % encode the 4 least significant bits
    [~, signal] = fsk_gen_1_period(f0, delta_f, M, T, Fs, mod(byte, 16));
    % add a delay of T
    signal = [signal, zeros(1, round(T*Fs))];
    % encode the 4 most significant bits
    [~, signal2] = fsk_gen_1_period(f0, delta_f, M, T, Fs, bitshift(byte, -4));
    % append the secnd signal
    signal = [signal, signal2];
end

% encode the message
% transform the message into decimal
message_decimal = uint8(message);
% we have each char as a 8 bit uint

delay_signal = zeros(1, round(T*Fs)); % of time T

tic
final_signal = [];
for i = 1:length(message_decimal)
    byte_signal = encode_byte(message_decimal(i), f0, delta_f, M, T, Fs);
    if i == 1
        final_signal = [byte_signal, delay_signal];
    else
        final_signal = [final_signal, byte_signal, delay_signal];
    end
end
toc

%normalize the signal
final_signal = final_signal/max(abs(final_signal));

if play_sound
    player = audioplayer(final_signal, Fs, 24, 1); % 1 is the ID of the macbook speaker
    play(player);   
else
    audiowrite('step_4_output.wav', final_signal, Fs);
    save("parameters.mat", "f0", "delta_f", "M", "T", "Fs");
end
