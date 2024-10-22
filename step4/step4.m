clc; clear; close all hidden;

% define the constants
M = 16;
f0 = 8000; % [Hz]
delta_f = 400; % [Hz]
Fs = 48000; % [Hz]

% delta_f = 1/(2*T) =>
T = 1/(2*delta_f);

message = 'hello sound communication';
% transform the message into decimal
binary_message = dec2bin(message, 8);
size(binary_message)
% transform the binary message into a vector appending all the bits
binary_message_vector = reshape(binary_message', 1, []);


function [t, signal] = fsk_gen_1_period(f0, detla_f, M, T, Fs, binary_chars)
    arguments
        f0 double
        detla_f double
        M double
        T double
        Fs double
        binary_chars (1, 16) char
    end

    % generate the time vector
    t = 0:1/Fs:T;
    % generate the signal
    signal = zeros(1, length(t));
    for m = 0:M-1
        if binary_chars(m+1) == '1'
            signal = signal + cos(2*pi*(f0 + m*detla_f)*t);
        end
    end

    % normalize the signal
    signal = signal/max(abs(signal));
end

[t, signal] = fsk_gen_1_period(f0, delta_f, M, T, Fs, binary_message_vector(1:16));

plot(t, signal);
xlabel('Time [s]');
ylabel('Amplitude');


% decode the fsk signal : 
function [decoded_message] = fsk_decode(signal, f0, delta_f, M, T, Fs)
    arguments
        signal double
        f0 double
        delta_f double
        M double
        T double
        Fs double
    end

    

end

