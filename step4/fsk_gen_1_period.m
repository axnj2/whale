function [t, signal, last_phase] = fsk_gen_1_period(f0, detla_f, M, T, Fs, number, use_random_phase, previous_phase)
    % idée d'amélioration : utiliser un code gray pour pouvoir corriger les erreurs plus facilement
    arguments
        f0 double
        detla_f double
        M double
        T double
        Fs double
        number int16
        use_random_phase double = 0
        previous_phase double = 0
    end

    if (number < 0 || number > M-1)
        error('fsk_gen_1_period() : The number must be between 0 and M-1');
    end

    % generate the time vector
    t = 0:1/Fs:T;
    t = t(1:end-1); % remove the last element to have the correct length (starts at 0)
    
    % generate the signal
    random_phase = randn(1,1)*pi*use_random_phase;

    signal = cos(2*pi*(f0 + double(number)*detla_f)*t + random_phase + previous_phase);

    last_phase = mod(2*pi*(f0 + double(number)*detla_f)*t(end) + random_phase + previous_phase, 2*pi);
    % normalize the signal (probably not necessary)
    signal = signal/max(abs(signal));
end