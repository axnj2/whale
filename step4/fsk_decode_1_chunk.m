function [decoded_message] = fsk_decode_1_chunk(signal, f0, delta_f, M, T, Fs)
    arguments (Input)
        signal (1,:) double  % transposes to have the good dimensions (column vector)
        f0 double
        delta_f double
        M double
        T double
        Fs double
    end

    arguments (Output) 
        decoded_message uint8
    end
    
    %verify size of entered signal
    if not(all(size(signal) == [1, floor(T*Fs)]))
        dimensions = size(signal);
        error("fsk_decode_1_period: incorrect signal size, should be [%d, %d] and is [%d, %d]", ...
            1, floor(T/Fs), dimensions(1), dimensions(2));    
    end

    figure;
    plot(abs(fft(signal)));

    % projection of the signal on the different base functions
    projections = zeros(1, M);
    for i = 0:M-1
        [~, base_signal] = fsk_gen_1_period(f0, delta_f, M, T, Fs, i);
        projections(i+1) = sum(signal.*base_signal);
    end

    % find the maximum projection
    [~, max_index] = max(projections);

    decoded_message = uint8(max_index - 1);
end