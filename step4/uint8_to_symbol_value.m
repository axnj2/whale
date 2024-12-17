function [symbol_values] = uint8_to_symbol_value(uint8_values, M)
    % Convert uint8 values to symbol values
    % Inputs:
    %   uint8_values: uint8 array of values to convert
    %   M: number of symbols, has to be a power of 2
    % Outputs:
    %   symbol_values: array of symbol values

    arguments (Input)
        uint8_values (1, :) uint8
        M double
    end

    arguments (Output)
        symbol_values (1, :) uint16
    end

    if log2(M) ~= round(log2(M))
        error("M has to be a power of 2");
    end

    if M > 2^16
        error("M has to be less than 2^16");
    end

    
    symbol_values = uintn_to_uintm(uint8_values, 8, log2(M));
end


