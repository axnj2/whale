clc; clear; close all hidden;

% choose between recording sound and loading from file
record_sound = false;
message_type = "text"; % "text" or "image"

if record_sound
    % define the constants
    M = 16;
    f0 = 8000; % [Hz]
    delta_f = 400; % [Hz]
    Fs = 48000; % [Hz]
    T = 10/(2*delta_f);

    %lengh of the message
    number_of_chunks = 2;
else
    % Load the data and parameters
    recorded_message = audioread("step_4_output.wav");
    load("parameters.mat", "f0", "delta_f", "M", "T", "Fs", "number_of_chunks");
end

if record_sound
    % listen for the incomming signal
    recorder = audiorecorder(Fs,24,1);
    record(recorder,T+3);

    pause(1);

    %store recorded message
    recorded_message = [getaudiodata(recorder)];
end


function [chunk_signal] = get_chunk(recorded_message, chunk_index, start_of_message, T, Fs)
    % chunk indices start at 1 for this function 
    %
    length_of_chunk = floor(T*Fs);
    chunk_index
    chunk_signal = recorded_message((start_of_message + (chunk_index-1)*2*length_of_chunk + 1):(start_of_message + ((chunk_index-1)*2+1)*length_of_chunk));
    %                                                                  ^^\ 2* to skip the delay
end

% TODO : find the start of the message
start_of_message = 0;


%decode 4 bites of the message :
chunks_value = zeros(1, number_of_chunks);
for i = 1:number_of_chunks
    chunks_value(i) = fsk_decode_1_chunk(get_chunk(recorded_message, i, start_of_message, T, Fs), f0, delta_f, M, T, Fs);
end

%decode the message
if message_type == "text"
    message = '';
    for i = 1:number_of_chunks/2
        byte = bitor(bitshift(chunks_value(2*i), 4), chunks_value(2*i-1));
        message(i) = char(byte);
    end
    disp(message);
else
    % TODO : decode the image
end



