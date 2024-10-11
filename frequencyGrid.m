function [t, signal, fk, n0] = frequencyGrid(Fs, T, f0, n1, kmax, randomPhase)
    arguments
        Fs double
        T double
        f0 double
        n1 double
        kmax double
        randomPhase logical = false
    end


    n0 = ceil(f0*T);
    
    fk = @(k)  (n0 + k*n1)/T;
    
    if randomPhase
        % random phase (+1 or -1)
        phase = 2*randi([0,1], 1, kmax+1) - 1;
    else
        phase = ones(1, kmax+1);
    end


    t = 0:1/Fs:T;
    t = t(1:end-1);
    signal = zeros(1,Fs*T);
    for k = 0:kmax
        signal = signal + sin(2*pi*fk(k)*t)*phase(k+1);
    end

    signal = signal/max(abs(signal));
end