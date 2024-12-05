clc; clear; close all hidden;

% choose between recording sound and loading from file
record_sound = false;
message_type = "image"; % "text" or "image"

if record_sound
    % define the constants
    M = 16;
    f0 = 8000; % [Hz]
    delta_f = 400; % [Hz]
    Fs = 48000; % [Hz]
    T = 8/(2*delta_f);

    %lengh of the message
    if message_type == "text"
        message_length = 25; % Caution this needs to be defined manually
        number_of_chunks = 2*message_length;
    elseif message_type == "image"
        image_height = 48; % Caution this needs to be defined manually
        image_width = 64; % Caution this needs to be defined manually
        number_of_chunks = (image_height * image_width)/4 + 4
    end


else
    % Load the data and parameters
    recorded_message = audioread("step_4_output.wav");
    load("parameters.mat", "f0", "delta_f", "M", "T", "Fs", "number_of_chunks", "message_type");
end

if number_of_chunks < 0
    error("message_length or image size needs to be defined manually");
end

if record_sound
    % listen for the incomming signal
    recorder = audiorecorder(Fs,24,1);
    record(recorder,5+ number_of_chunks*T*2);

    pause(6+ number_of_chunks*T*2);

    %store recorded message
    recorded_message = [getaudiodata(recorder)];
    visualise_signal_spectrum(T, Fs, recorded_message);
end

function [t0_index, window_size] = find_start_of_message(recorded_message, f0, delta_f, M, T, Fs)
    % find the start of the message
    % the message starts with a f0 frequency for T seconds
    window_time = 10/(f0);
    window_size = floor(window_time*Fs);

    f0_powers = zeros(1, floor(length(recorded_message)/window_size));
    % loop until we find a jump in the fft for the f0 frequency
    for i = 1:floor(length(recorded_message)/window_size)-1
        window = recorded_message((i-1)*window_size+1:i*window_size);
        fft_window = fft(window);
        
        % frequencies are given by : Fs/(window_size)*(-Q:(Q)-1)
        [~, f0_index] = find(Fs/(window_size)*(0:window_size/2) == f0);
        f0_powers(i) = abs(fft_window(f0_index));
        if i > 21
            if f0_powers(i) > 20*mean(f0_powers(i-21:i-1))
                t0_index = (i-1)*window_size + window_size/2 ;
                break
            end
        else
            if f0_powers(i) > 1e-1 % FIXME :  might not work for recorded sound, has been tested with no issue.
                t0_index = (i-1)*window_size + window_size/2 +2;
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

%decode 4 bites of the message :
chunks_value = zeros(1, number_of_chunks);
for i = 1:number_of_chunks
    chunks_value(i) = fsk_decode_1_chunk(get_chunk(recorded_message, i, start_of_message, T, Fs, incertitude_window_size),...
     f0, delta_f, M, T-10/f0, Fs, true);
end

bytes_of_message = zeros(1, number_of_chunks/2);
for i = 1:number_of_chunks/2
    bytes_of_message(i) = bitor(bitshift(chunks_value(2*i), 4), chunks_value(2*i-1));
end

%decode the message
if message_type == "text"
    message = '';
    for i = 1:number_of_chunks/2
        message(i) = char(bytes_of_message(i));
    end
    disp(message);
else
    received_image = decode_image_from_uint8(bytes_of_message);
    imagesc(received_image);

    %calculate error rate : 
    perfect_image = format_image(imread('image.jpg'));
    error_rate = sum(received_image ~= perfect_image, 'all')/(size(received_image,1)*size(received_image,2));
end



