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
message_decimal = int8(message);


function [t, signal] = fsk_gen_1_period(f0, detla_f, M, T, Fs, number)
    arguments
        f0 double
        detla_f double
        M double
        T double
        Fs double
        number int8
    end

    % generate the time vector
    t = 0:1/Fs:T;
    % generate the signal
    signal = zeros(1, length(t));
    % transform binart chars into int using bin2dec
    signal = signal + cos(2*pi*(f0 + double(number)*detla_f)*t);

    % normalize the signal
    signal = signal/max(abs(signal));
end
% with 16 possibles values we can store 4 bits
[t, signal] = fsk_gen_1_period(f0, delta_f, M, T, Fs, mod(message_decimal(1), 16));

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

