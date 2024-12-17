function [uint8_values] = symbol_value_to_uint8(symbol_values, M)
    % Convert symbol values to uint8 values
    % caution, the length of uint8_value might have an additionnal 0 at the end 
    % but all the other values are garantied
    % Inputs:
    %   symbol_values: array of symbol values
    %   M: number of symbols, has to be a power of 2
    % Outputs:
    %   uint8_values: uint8 array of values

    arguments (Input)
        symbol_values (1, :) uint16
        M double
    end

    arguments (Output)
        uint8_values (1, :) uint8
    end

    if log2(M) ~= round(log2(M))
        error("M has to be a power of 2");
    end

    if M > 2^16
        error("M has to be less than 2^16");
    end

    uint8_values = uintn_to_uintm(symbol_values, log2(M), 8);
end

