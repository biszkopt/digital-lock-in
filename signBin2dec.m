function dec = signBin2dec(word)

    bits = length(word);
    bit_range = 2^(bits-1);

    accumulator = (-1) * str2num(word(1)) * bit_range;

    for current_index = 2:bits
    
        current_bit = str2num(word(current_index));
        bit_range = 2^(bits - current_index);

        accumulator = accumulator + current_bit * bit_range;
    
    end
    
    dec = accumulator;
    
end