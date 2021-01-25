function signal = readFromFile(out_bits,uref,uref_power,filepath,binary)

    file_from_fpga = fopen(filepath,'r');

    if binary == true
        
        signal_fpga_out = fscanf(file_from_fpga,'%s');
    
        number_of_lines = length(signal_fpga_out)/(out_bits+1); % that's because matlab loads all bits into one line
        
        signal = signBinStr2dec(signal_fpga_out, out_bits, number_of_lines);
        

        signal = signal/(2^out_bits - 1) * uref^uref_power;
        
    else % binary == false
        signal_fpga_out = fscanf(file_from_fpga,'%d');

        signal = signal_fpga_out/(2^out_bits - 1) * uref^uref_power;
    end
    
    fclose(file_from_fpga);
end