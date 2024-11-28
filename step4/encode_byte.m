function [signal] = encode_byte(byte, f0, delta_f, M, T, Fs, relative_delay_duration)
    % we first select the 4 least significant bits with mod(a, 16) and then the 4 most significant bits with bitshift(a, -4)
    arguments
        byte uint8
        f0 double
        delta_f double
        M double
        T double
        Fs double
        relative_delay_duration double = 1
    end

    % encode the 4 least significant bits
    [~, signal] = fsk_gen_1_period(f0, delta_f, M, T, Fs, mod(byte, 16));
    % add a delay of T*relative_delay_duration
    signal = [signal, zeros(1, round(T*Fs*relative_delay_duration))];
    % encode the 4 most significant bits
    [~, signal2] = fsk_gen_1_period(f0, delta_f, M, T, Fs, bitshift(byte, -4));
    % append the secnd signal
    signal = [signal, signal2];
    % add a delay of T*relative_delay_duration
    signal = [signal, zeros(1, round(T*Fs*relative_delay_duration))];
end