function [chunk_signal] = get_chunk(recorded_message, chunk_index, start_of_message, chunck_duration, Fs,...
                                    incertitude_window_size, relative_delay_duration)
    % chunk indices start at 1 for this function 
    % assumes delay of T*relative_delay_duration between each chunk
    arguments
        recorded_message double
        chunk_index double
        start_of_message double
        chunck_duration double
        Fs double
        incertitude_window_size double
        relative_delay_duration double = 1
    end

    length_of_chunk = round(chunck_duration*Fs);

    chunk_signal = recorded_message((start_of_message + 1 +  (chunk_index-1)*(1+relative_delay_duration)    * length_of_chunk)    + incertitude_window_size/2 :...
                                    (start_of_message     + ((chunk_index-1)*(1+relative_delay_duration)+1) * length_of_chunk) - incertitude_window_size/2);
    %takes into account the incertitude on the intial time

end