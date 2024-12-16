function [decoded_message] = fsk_decode_1_chunk(signal, f0, delta_f, M, T, Fs, non_coherent)
    arguments (Input)
        signal (1,:) double  % transposes to have the good dimensions (column vector)
        f0 double
        delta_f double
        M double
        T double
        Fs double
        non_coherent int8 = 0
    end

    arguments (Output) 
        decoded_message uint8
    end
    
    %verify size of entered signal
    if not(all(size(signal) == [1, floor(T*Fs)]))
        dimensions = size(signal);
        error("fsk_decode_1_period: incorrect signal size, should be [%d, %d] and is [%d, %d]", ...
            1, floor(T*Fs), dimensions(1), dimensions(2));    
    end

    % check if the isapprox() function is available
    try
        isapprox(1, 1);
    catch err
        % if err.identifier == "MATLAB:UndefinedFunction"
        %     warning('foo:bar',"upgrade to MATLAB R2024b or later to use the isapprox() function\n this script will use exact comparison instead");
        % end
        isapprox = @(a, b) a == b;
        clear err;
    end

    % check the ortogonality conditions
    if non_coherent
        if ~isapprox(mod(round(f0*2*T, 7),  1), 0)
            error("fsk_decode_1_chunk : f0 does not meet the orthogonality requirements. f0 = %g, T = %g, f0*2*T = %g", f0, T, f0*2*T);
        elseif ~isapprox(mod(round(delta_f*T, 7), 1), 0)
            error("fsk_decode_1_chunk : delta_f does not meet the orthogonality requirements. delta_f = %g, T = %g, delta_f*T = %g", delta_f, T, delta_f*T);
        end
    end

    % projection of the signal on the different base functions
    projections = zeros(1, M);
    for i = 0:M-1
        if non_coherent
            % generate the time vector
            t = 0:1/Fs:T;
            t = t(1:end-1);

            % generate the signal
            base_signal = exp(1i*2*pi*(f0 + i*delta_f)*t);
    
        else
            [~, base_signal] = fsk_gen_1_period(f0, delta_f, M, T, Fs, i);
        end
        
        projections(i+1) = abs(sum(signal.*base_signal));
    end

    % find the maximum projection
    [~, max_index] = max(projections);

    decoded_message = uint8(max_index - 1);
end