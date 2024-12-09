clc; clear; close all hidden;


% switch between playing sound and saving to file for testing
play_sound = false;

% define the constants
M = 16;
f0 = 8000; % [Hz]
delta_f = 400; % [Hz]
Fs = 48000; % [Hz]

% delta_f = 1/(2*T) =>
T = 8/(2*delta_f);

Delay_before_start = 1000 + 11; % [samples]

message_type = "image"; % "text" or "image"

if message_type == "text"
    message = 'hello sound communication';
elseif message_type == "image"
    raw_image = imread('image.jpg');
    image = format_image(raw_image);
    imagesc(image);
    % convert the image to a message
    message = encode_image_to_uint8(image);
end
%message = 'h';


% encode the message
% transform the message into decimal
message_decimal = uint8(message);
% we have each char as a 8 bit uint

delay_signal = zeros(1, round(T*Fs)); % of time T

number_of_chunks = length(message_decimal)*2;

% add preamble to the signal for 1 period at f0
[~, preamble] = fsk_gen_1_period(f0, delta_f, M, T, Fs, 0);
final_signal = [preamble, zeros(1, round(T*Fs))];

for i = 1:number_of_chunks/2
    byte_signal = encode_byte(message_decimal(i), f0, delta_f, M, T, Fs);
    final_signal = [final_signal, byte_signal];
end

%normalize the signal
final_signal = final_signal/max(abs(final_signal));
final_signal = [zeros(1, Delay_before_start), final_signal];

if play_sound
    player = audioplayer(final_signal, Fs, 24, 1); % 1 is the ID of the macbook speaker
    play(player);   
else
    audiowrite('step_4_output.wav', final_signal, Fs);
    save("parameters.mat", "f0", "delta_f", "M", "T", "Fs", "number_of_chunks", "message_type");
end

% spectral power density

[spectral_power_density, w] = pwelch(final_signal);
figure;
 plot(w/pi, 10*log10(spectral_power_density));