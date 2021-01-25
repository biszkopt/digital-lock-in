function dec_array = signBinStr2dec(input_string, bit_length, number_of_lines)

    for i = 1:number_of_lines
        
        start_index = (i-1)*bit_length + 1;
        end_index = (i)*bit_length + 1;
        
        word = input_string( start_index : end_index );
        
        dec_array(i) = signBin2dec(word);
    end

end

