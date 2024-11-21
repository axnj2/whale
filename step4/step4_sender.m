clc; clear; close all hidden;

% define the constants
M = 16;
f0 = 8000; % [Hz]
delta_f = 400; % [Hz]
Fs = 48000; % [Hz]

% delta_f = 1/(2*T) =>
T = 10/(2*delta_f)

message = 'hello sound communication';
% transform the message into decimal
message_decimal = uint8(message);


% we have each char as a 8 bit uint
% we first select the 4 least significant bits with mod(a, 16) and then the 4 most significant bits with bitshift(a, -4)

% with 16 possibles values we can store 4 bits
[t, signal] = fsk_gen_1_period(f0, delta_f, M, T, Fs, 0);
[t, signal2] = fsk_gen_1_period(f0, delta_f, M, T, Fs, 7);

signal2 = signal2 + 1*randn(1, length(signal2));

