function [chunk_signal] = get_chunk(recorded_message, chunk_index, start_of_message, T, Fs,...
                                    incertitude_window_size, relative_delay_duration)
    % chunk indices start at 1 for this function 
    % assumes delay of T*relative_delay_duration between each chunk
    arguments
        recorded_message double
        chunk_index double
        start_of_message double
        T double
        Fs double
        incertitude_window_size double
        relative_delay_duration double = 1
    end

    length_of_chunk = floor(T*Fs);
    chunk_signal = recorded_message((start_of_message + (chunk_index-1)*(1+relative_delay_duration)*length_of_chunk + 1 ):...
    ...                                                                   ^\ 2* to skip the delay
                                    (start_of_message + ((chunk_index-1)*(1+relative_delay_duration)+1)*length_of_chunk));
    %take into account the incertitude on the intial time


    chunk_signal = chunk_signal((incertitude_window_size/2 +1):end-incertitude_window_size/2);
end