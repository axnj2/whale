function [decoded_message] = fsk_decode_1_period(signal, f0, delta_f, M, T, Fs)
    arguments
        signal double
        f0 double
        delta_f double
        M double
        T double
        Fs double
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