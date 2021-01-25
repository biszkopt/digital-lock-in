function signal = generateSineSum(N, fs, A, f_norm, phi, DC)

    n = 0:1:N-1;

    f = fs * f_norm;
    
    signal = sum(A .* sin(2*pi*f.*n.' + phi),2) + DC;
end