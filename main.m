use_phase_shifter = true;

%% generating signal & local oscillator
fs = 1;
N = 250;
uref = 3.3;

DC = 0;

A =     [0.5    1];
f =     [0.125   0.4];
phi =   [0    0];

% params: samples, sampling freq, amplitudes, normalised freq, phase, DC
sig = generateSineSum(N, fs, A, f, phi, DC);

A_lo = 1;
f_lo = 0.125;
phi_lo = 0;
sig_lo = generateSineSum(N, fs, A_lo, f_lo, phi_lo, DC);

if use_phase_shifter == false
    phi_lo_iq = pi/2;
    sig_lo_iq = generateSineSum(N, fs, A_lo, f_lo, phi_lo_iq, DC);
end


%% preparing data for vivado and saving to a file
in_bits = 7; % unsigned bits
in_bits_lo = 14; % unsigned bits
input_data_file = 'data_in.txt';
input_lo_file = 'lo_in.txt';

if use_phase_shifter == false
    input_lo_iq_file = 'lo_iq_in.txt';
end

% params: signed input bits, reference voltage, signal, file path
% returns: signal in binary
sig_bin = saveToFile(in_bits,3.3,sig,input_data_file);
sig_lo_bin = saveToFile(in_bits_lo,3.3,sig_lo,input_lo_file);

if use_phase_shifter == false
    sig_lo_iq_bin = saveToFile(in_bits_lo,3.3,sig_lo_iq,input_lo_iq_file);
end
    
% keyboard(); % wait for vivado sim to finish

%% reading data back from vivado
out_bits = 16; % signed
uref_power = 2; % this actually represents number of times signal that had been normalised relative to uref were multiplicated with one another
file_data_out = 'data_out.txt';
file_data_out_iq = 'data_out_iq.txt';

                    % params: output bits, uref, uref_normalised_signals, filepath, binary
sig_fpga_demod_filtered = readFromFile(out_bits, uref, uref_power, file_data_out, true);
sig_fpga_demod_filtered = sig_fpga_demod_filtered(2:end);

sig_fpga_demod_filtered_iq = readFromFile(out_bits, uref, uref_power, file_data_out_iq, true);
sig_fpga_demod_filtered_iq = sig_fpga_demod_filtered_iq(2:end);

%% processing signal in matlab using same path
% filter 1
freqs =     [0      0.5    0.7     1];
amps =      [1      1      0       0];
weights =   [1000      100];
order = 7;
b = firpm(order, freqs, amps, weights);

sig_filtered = filter(b,1,sig);

% demodulation
samples_delay = 1/4*1/f_lo;

if floor(samples_delay)~=samples_delay
    error('Samples_delay is not an integer!')
end

if use_phase_shifter == false
else
    sig_lo_iq = circshift(sig_lo,samples_delay);
end

sig_demod = sig_filtered .* sig_lo;
sig_demod_iq = sig_filtered .* sig_lo_iq;

% filter 2
freqs =     [0      0.1    0.385    1];
amps =      [1      1      0       0];
weights =   [50      100];
order = 7;
b = firpm(order, freqs, amps, weights);

sig_demod_filtered = filter(b,1,sig_demod);
sig_demod_filtered_iq = filter(b,1,sig_demod_iq);

%% FPGA implementation simulation in matlab

% filter 1
in_bits = 7; % unsigned
freqs =     [0      0.5    0.7     1];
amps =      [1      1      0       0];
weights =   [1000      100];
order = 7;
b = firpm(order, freqs, amps, weights);
b_bin = floor(b*(2^in_bits - 1)) / (2^in_bits - 1);
sig_bin = sig_bin / (2^in_bits - 1) * uref;

sig_filtered_bin = filter(b_bin,1,sig_bin);

% demodulation
in_bits = 14; % unsigned

sig_lo_bin = sig_lo_bin / (2^in_bits - 1) * uref;

if use_phase_shifter == false
    sig_lo_iq_bin = sig_lo_iq_bin / (2^in_bits - 1) * uref;
else
    sig_lo_iq_bin = circshift(sig_lo_bin,samples_delay);
end

sig_demod_bin = sig_filtered_bin .* sig_lo_bin;
sig_demod_iq_bin = sig_filtered_bin .* sig_lo_iq_bin;

% filter 2
in_bits = 28; % unsigned
freqs =     [0      0.1    0.385    1];
amps =      [1      1      0       0];
weights =   [50      100];
order = 7;
b = firpm(order, freqs, amps, weights);
b_bin = floor(b*(2^in_bits - 1)) / (2^in_bits - 1);

sig_demod_filtered_bin = filter(b_bin,1,sig_demod_bin);
sig_demod_filtered_iq_bin = filter(b_bin,1,sig_demod_iq_bin);


%%
figure;
subplot(1,3,1); hold on
    plot(sig_demod_filtered)
    plot(sig_demod_filtered_iq)
    title('Przetwarzanie w Matlabie')
    legend({"W fazie", "W kwadraturze"})
    xlabel("Numer probki")
    ylabel("Napiecie [V]")
    ylim([-0.3 0.3])

subplot(1,3,2); hold on
    plot(sig_fpga_demod_filtered)
    plot(sig_fpga_demod_filtered_iq)
    title('Przetwarzanie na FPGA')
    legend({"W fazie", "W kwadraturze"})
    xlabel("Numer probki")
    ylabel("Napiecie [V]")
    ylim([-0.3 0.3])

subplot(1,3,3); hold on
    plot(sig_demod_filtered_bin)
    plot(sig_demod_filtered_iq_bin)
    title('Symulacja FPGA w Matlabie')
    legend({"W fazie", "W kwadraturze"})
    xlabel("Numer probki")
    ylabel("Napiecie [V]")
    ylim([-0.3 0.3])

I = mean(sig_fpga_demod_filtered);
Q = mean(sig_fpga_demod_filtered_iq);
magnitdue = 2*sqrt(I^2 + Q^2)
phase = rad2deg(atan(Q/I))

measured = sig_fpga_demod_filtered(25:225);
real = sig_demod_filtered(25:225).';
mean_abs_error_ip = mean( abs(measured - real) )
mean_rel_error_ip = mean( abs(measured - real)./abs(real) )*100