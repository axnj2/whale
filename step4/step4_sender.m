clear; close all; clc;


% switch between playing sound and saving to file for testing
play_sound = false;

message_type = "image"; % "text" or "image"

image_height = 0;
image_width = 0;
if message_type == "text"
    message = 'hello sound communication';
elseif message_type == "image"
    raw_image = imread('image.jpg');
    image = format_image(raw_image);
    image_height = size(image, 1);
    image_width = size(image, 2);
    figure
    imagesc(image);
    % convert the image to a message
    message = encode_image_to_uint8(image);
    title('Original image');
end

% define the constants
Delay_before_start = 1000; % [samples]

% delay between each chunk as a fraction of T
relative_delay_duration = 0;

Fs = 48000; % [Hz]
M = 4;
delta_f = Fs/7 %#ok<NOPTS> % [Hz]
f0 = delta_f/2 %#ok<NOPTS> % [Hz]


% Computing the maximum frequency with an integer number of samples 
% in the bandwith to use it as a preamble
f_int_max = 1/(ceil(Fs/(f0+(M-1)*delta_f))/Fs); % computes the min number of samples corresponding to a frequency in the bandwith

% delta_f = 1/T =>
T_min = 1/delta_f; % [s]
T = T_min + 4/f_int_max; % [s] adds a small margin to allow for truncating at the receiver

% check if the isapprox() function is available
try
    isapprox(1, 1);
catch err
    if err.identifier == "MATLAB:UndefinedFunction"
        warning('foo:bar',"upgrade to MATLAB R2024b or later to use the isapprox() function\n this script will use exact comparison instead");
    end
    isapprox = @(a, b) a == b;
    clear err;
end

% check the orthogonality requirements of the signal for a non-coherent receiver
% f0 = k/(2*T) where k is an integer
% delta_f = k/(T) where k is an integer
if ~isapprox(mod(round(f0*2*T_min, 7), 1),  0)
    error("f0 does not meet the orthogonality requirements");
elseif ~isapprox(mod(round(delta_f*T_min, 7), 1), 0)
    error("delta_f does not meet the orthogonality requirements");
end

% check that the signal duration is long enough to allow for some trunkating at the receiver
% as the detection of the start of the message is imperfect
if T < T_min - 1/f0
    error("T is too short to allow for truncating at the receiver");
end


%check that the highest frequency is below the Nyquist frequency
if f0 + (M-1)*delta_f > Fs/2
    error("f0 + (M-1)*delta_f  = F_max > Fs/2");
end

% check that the highest frequency is below 18 kHz
if f0 + (M-1)*delta_f > 18000
    warning("f0 + (M-1)*delta_f  = F_max > 18000 Hz, might not be recorded by the microphone");
end

% check that T_min*Fs is an integer
if ~isapprox(round(T_min*Fs, 7), round(T_min*Fs))
    error("T_min*Fs is not an integer");
end

% check that T*Fs is an integer
if ~isapprox(round(T*Fs, 7), round(T*Fs))
    error("T*Fs is not an integer");
end



% encode the message
% transform the message into decimal (does not change anything if it is already in decimal)
message_decimal = uint8(message);
chuncks_values = uint8_to_symbol_value(message_decimal, M);
number_of_chunks = length(chuncks_values);

% add preamble to the signal for 1 period at f0 
% (used in the receiver to find the start of the message)
[~, preamble] = fsk_gen_1_period(f_int_max, delta_f, M, T, Fs, 0);
final_signal = [preamble, zeros(1, round(T*Fs))];

% make it longer to include a delay between each symbol if specified
chunck_signal = zeros(1, round(T*Fs));

previous_phase =pi/2;
for i = 1:number_of_chunks
    [~, chunck_signal, previous_phase] = fsk_gen_1_period(f0, delta_f, M, T, Fs, chuncks_values(i), false, previous_phase);
    final_signal = [final_signal, chunck_signal];
end

%normalize the signal
final_signal = final_signal/max(abs(final_signal));

message_duration = length(final_signal)/Fs %#ok<NOPTS>
bit_rate = log2(M)/T %#ok<NOPTS>

if play_sound
    player = audioplayer(final_signal, Fs, 24); 
    play(player);   
else
    % add a delay before the start of the message to test 
    % the dectection of the start of the message in the receiver
    final_signal = [zeros(1, Delay_before_start), final_signal]; %#ok<*UNRCH>
    audiowrite('step_4_output.wav', final_signal, Fs);
    save("parameters.mat", "f0", "delta_f", "M", "T", "T_min", "Fs", "number_of_chunks", "message_type",...
                "relative_delay_duration", "image_width", "image_height");
end

% spectral power density
[spectral_power_density, w] = pwelch(final_signal);

figure;
plot(w/pi*Fs/2, 10*log10(spectral_power_density));
xlabel('Frequency [Hz]');
ylabel('Power/Frequency [dB/Hz]');
title('Spectral power density of the signal');