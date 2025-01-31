clc; clear; close all hidden;


% D'ABORD RUN LE FICHIER step4_sender.m


% choose between recording sound and loading from file
record_sound = false;
message_type = "image"; % "text" or "image"

if record_sound % not used when loading from file
    % define the constants
    Fs = 48000; % [Hz]
    M = 4;
    delta_f = Fs/7 %#ok<NOPTS> % [Hz]
    f0 = delta_f/2 %#ok<NOPTS> % [Hz]
    T_min = 1/delta_f;
    f_int_max = 1/(ceil(Fs/(f0+(M-1)*delta_f))/Fs);
    T = T_min + 4/f_int_max;

    relative_delay_duration = 0;

    %lengh of the message
    if message_type == "text"
        message_length = 25; % Caution this needs to be defined manually
        number_of_chunks = 2*message_length;
    elseif message_type == "image"
        image_height = 192; % Caution this needs to be defined manually
        image_width = 255; % Caution this needs to be defined manually
        number_of_chunks = (image_height * image_width)/4 + 4
    end


else
    % Load the data and parameters
    recorded_message = audioread("step_4_output.wav");
    load("parameters.mat", "f0", "delta_f", "M", "T", "T_min", "Fs", "number_of_chunks", "message_type",...
           "relative_delay_duration", "image_height", "image_width");
end

if number_of_chunks < 0
    error("message_length or image size needs to be defined manually");
end

if record_sound
    % listen for the incomming signal
    recorder = audiorecorder(Fs,24,1);
    record(recorder,5+ number_of_chunks*T*2);

    pause(20 + number_of_chunks*T);

    %store recorded message
    recorded_message = [getaudiodata(recorder)];
    %visualise_signal_spectrum(T, Fs, recorded_message, true, true);
end

function [t0_index, window_size] = find_start_of_message(recorded_message, f0, delta_f, M, T, Fs)
    arguments
        recorded_message (1, :) double % changes the shape of the recorded message to a row vector
        f0 double
        delta_f double
        M double
        T double
        Fs double
    end

    % find the start of the message
    % the message starts with a f0 frequency for T second
    % f_int_max = 1/(ceil(Fs/(f0+(M-1)*delta_f))/Fs); % computes the min number of samples corresponding to a frequency in the bandwith
    % window_time = 1/f_int_max;
    window_size = ceil(Fs/(f0+(M-1)*delta_f));

    time_vector = (0:length(window_size)-1)/Fs;
    base_vector = exp(1i*2*pi*f0*time_vector);

    f0_powers = zeros(1, floor(length(recorded_message)/window_size));
    % loop until we find a jump in the fft for the f0 frequency
    for i = 1:floor(length(recorded_message)/window_size)-1
        window = recorded_message((i-1)*window_size+1:i*window_size);
        projection = abs(sum(window .* base_vector));
        
        f0_powers(i) = abs(projection);
        if i > 21
            if f0_powers(i) > 15*mean(f0_powers(i-21:i-1))
                t0_index = (i-1)*window_size + floor(window_size/2) ;
                break
            end
        else
            if f0_powers(i) > 1e-1 % might not work for recorded sound, has been tested with no issue.
                t0_index = (i-1)*window_size + floor(window_size/2) +2;
                break
            end
        end
    end

    if exist("t0_index", "var") == 0
        error("could not find the start of the message");
    end

    t0_index = t0_index + 2*T*Fs; % to account for the 
end


[start_of_message, incertitude_window_size] = find_start_of_message(recorded_message, f0, delta_f, M, T, Fs);
start_of_message
incertitude_window_size = 4 * incertitude_window_size;

% validate assumption used in get_chunk and fsk_decode_1_chunk (in the loop below)
% it's bad practice to use == with floating point numbers, but the isapprox() function was only introduced in R2024b
if T ~= 1/delta_f + incertitude_window_size/Fs || T_min ~= 1/delta_f 
    error("T is not equal to 1/delta_f + 4/f0 = T_min + 4/f0");
end

%decode 4 bites of the message :
non_coherent = true;
chunks_value = zeros(1, number_of_chunks);
for i = 1:number_of_chunks
    chunks_value(i) = fsk_decode_1_chunk(get_chunk(recorded_message, i, start_of_message, T, Fs, incertitude_window_size, relative_delay_duration),...
     f0, delta_f, M, 1/delta_f, Fs, non_coherent);
end

bytes_of_message = symbol_value_to_uint8(chunks_value, M);

%decode the message
if message_type == "text"
    message = '';
    for i = 1:length(bytes_of_message)
        message(i) = char(bytes_of_message(i));
    end
    disp(message);
elseif message_type == "image"
    try
        received_image = decode_image_from_uint8(bytes_of_message, image_height, image_width);
    catch err
        disp(err.message);
        bytes_of_message = bytes_of_message(1:end-1); % removes the added 0 from the conversion from symbol to uint8
        received_image = decode_image_from_uint8(bytes_of_message, image_height, image_width);
    end
    imagesc(received_image);
    colormap("gray")
    hold on
    %calculate error rate : 
    perfect_image = format_image(imread('image.jpg'));
    error_rate = sum(received_image ~= perfect_image, 'all')/(size(received_image,1)*size(received_image,2))
    [errorsx, errorsy] = find(received_image ~= perfect_image);
    plot(errorsy, errorsx, 'r.', 'MarkerSize', 5);

    title("received image (errors in red)");
else
    error("message_type not supported or not defined");
end



