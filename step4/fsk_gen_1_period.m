function [t, signal] = fsk_gen_1_period(f0, detla_f, M, T, Fs, number, random_phase)
    % idée d'amélioration : utiliser un code gray pour pouvoir corriger les erreurs plus facilement
    arguments
        f0 double
        detla_f double
        M double
        T double
        Fs double
        number int8
        random_phase double = 0
    end

    if (number < 0 || number > M-1)
        error('fsk_gen_1_period() : The number must be between 0 and M-1');
    end

    % generate the time vector
    t = 0:1/Fs:T;
    t = t(1:end-1); % remove the last element to have the correct length (starts at 0)
    
    % generate the signal

    signal = cos(2*pi*(f0 + double(number)*detla_f)*t + randn(1,1)*pi*random_phase);

    % normalize the signal
    signal = signal/max(abs(signal));
end