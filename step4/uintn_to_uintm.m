function [uintm_values] = uintn_to_uintm(uintn_values, n, m)
    % Convert uintn values to uintm values
    % Inputs:
    %   uintn_values: uintn array of values to convert
    %   n: number of bits in the uintn values
    %   m: number of bits in the uintm values
    % Outputs:
    %   uintm_values: uintm array of values

    arguments (Input)
        uintn_values (1, :) uint64
        n (1,1) double {mustBeLessThan(n, 64)}
        m (1,1) double {mustBeLessThan(m, 64)}
    end

    arguments (Output)
        uintm_values (1, :) uint64
    end

    number_of_uintm_values = ceil(length(uintn_values)*n/m);
    uintm_values = zeros(1, number_of_uintm_values, "uint64");

    % loop through each bit in the uintn_values
    for i_bit = 1:n*length(uintn_values)
        % get the bit value
        bit_value = bitget(uintn_values(ceil(i_bit/n)), mod(i_bit-1, n)+1, "uint64");
        % add the bit value to the uintm value
        uintm_values(ceil(i_bit/m)) = bitset(uintm_values(ceil(i_bit/m)), mod(i_bit-1, m)+1, bit_value, "uint64");
    end
end