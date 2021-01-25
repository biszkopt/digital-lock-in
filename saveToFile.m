function signal_binary = saveToFile(in_bits,uref,signal,filepath)

    bit_range = (2^in_bits)-1;

    signal_normalised = signal/uref;
    signal_binary = floor(signal_normalised * bit_range);

    dlmwrite(filepath, signal_binary,'delimiter','');
end
