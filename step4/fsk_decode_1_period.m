function [decoded_message] = fsk_decode_1_period(signal, f0, delta_f, M, T, Fs)
    arguments
        signal (1,:) double  % check if signal is a line vector
        f0 double
        delta_f double
        M double
        T double
        Fs double
    end
    
    %verify size of entered signal
    if not(min(size(signal) == [1, floor(T/Fs)]))
        dimensions = size(signal);
        error("fsk_decode_1_period: incorrect signal size, should be [%d, %d] and is [%d, %d]", ...
            1, floor(T/Fs), dimensions(1), dimensions(2));    
    end

    % projection of the signal on the different base functions
    projections = zeros(1, M);
    for i = 0:M-1
        [t, base_signal] = fsk_gen_1_period(f0, delta_f, M, T, Fs, i);
        projections(i+1) = sum(signal.*base_signal);
    end

    % find the maximum projection
    [max_value, max_index] = max(projections);

    decoded_message = max_index - 1;
end