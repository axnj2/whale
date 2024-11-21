function [t, signal] = fsk_gen_1_period(f0, detla_f, M, T, Fs, number)
    % idée d'amélioration : utiliser un code gray pour pouvoir corriger les erreurs plus facilement
    arguments
        f0 double
        detla_f double
        M double
        T double
        Fs double
        number int8
    end

    if (number < 0 || number > M-1)
        error('fsk_gen_1_period() : The number must be between 0 and M-1');
    end

    % generate the time vector
    t = 0:1/Fs:T;
    % generate the signal

    signal =cos(2*pi*(f0 + double(number)*detla_f)*t);

    % normalize the signal
    signal = signal/max(abs(signal));
end