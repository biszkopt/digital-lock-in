%% generating signal & local oscillator
fs = 1;
N = 250;
uref = 3.3;

DC = 0;

A =     [0.5    1];
f =     [0.125   0.4];
phi =   [0    0];

%params: samples, sampling freq, amplitudes, normalised freq, phase, DC
sig = generateSineSum(N, fs, A, f, phi, DC);

A_lo = 1;
f_lo = 0.125;
phi_lo = 0;
sig_lo = generateSineSum(N, fs, A_lo, f_lo, phi_lo, DC);


%% preparing data for vivado and saving to a file
in_bits = 7;
in_bits_lo = 14;
input_data_file = 'data_in.txt';
input_lo_file = 'lo_in.txt';

% params: input bits, reference voltage, signal, file path
% returns: signal in binary
sig_bin = saveToFile(in_bits,3.3,sig,input_data_file);
sig_lo_bin = saveToFile(in_bits_lo,3.3,sig_lo,input_lo_file);


keyboard(); % wait for vivado sim to finish



%% reading data back from vivado
%out_bits = 14;
out_bits = 16;
uref_power = 2;
file_data_out = 'data_out.txt';
file_data_out_iq = 'data_out_iq.txt';

                    % params: output bits, uref, uref_normalised_signals,
                    % filepath, binary
                    
                    % uref_normalised_signals <- this parameter is
                    % important! you need to keep track of how many times
                    % normalised signals were multiplied by each other as
                    % it raises power of uref in final equation
                    
sig_fpga_filtered_demod = readFromFile(out_bits, uref, uref_power, file_data_out, true);
sig_fpga_filtered_demod = sig_fpga_filtered_demod(2:end);

sig_fpga_filtered_demod_iq = readFromFile(out_bits, uref, uref_power, file_data_out_iq, true);
sig_fpga_filtered_demod_iq = sig_fpga_filtered_demod_iq(2:end);

%% matlab filter using same coefficients
freqs =     [0      0.5    0.7     1];
amps =      [1      1      0       0];
weights =   [1000      100];
order = 7;
b = firpm(order, freqs, amps, weights);
% freqz(b,1,200)


% ext = zeros(10,1);
% sig_ext = [sig; ext];
sig_filtered = filter(b,1,sig);

sig_matlab_filtered_fp = sig_filtered;

%% FPGA implementation simulation in matlab
b_bin = floor(b*(2^in_bits - 1));
% sig_bin_ext = [sig_bin; ext];
%sig_matlab_filtered_bin = filter(b_bin,1,sig_bin) / (2^out_bits - 1) * uref;
sig_matlab_filtered_bin = filter(b_bin,1,sig_bin) / (2^14 - 1) * uref;


%% plots
% figure;
% plot(sig_matlab_filtered_fp)
% hold on
% plot(sig_matlab_filtered_bin)
% plot(sig_fpga_filtered(2:end)) % (2:end) to skip the first zero
% legend({'Matlab (full precision)','Matlab (8 bit precision)','FPGA'});

%% demodulacja

sig_demod = sig_filtered .* sig_lo;

sig_lo_bin = sig_lo_bin/(2^14 - 1) * uref;
sig_matlab_filtered_demod_bin = sig_matlab_filtered_bin .* sig_lo_bin;

sig_matlab_filtered_demod = sig_demod;

%figure;
%plot(sig_matlab_filtered_demod)
%hold on
%plot(sig_fpga_filtered_demod)
%figure;
%plot(sig_demod_filtered)

freqs =     [0      0.1    0.385    1];
amps =      [1      1      0       0];
weights =   [50      100];
order = 7;
b = firpm(order, freqs, amps, weights);
%freqz(b,1,200)
sig_matlab_filtered_demod_filtered = filter(b,1,sig_demod);

figure;
plot(sig_matlab_filtered_demod_filtered)
hold on
plot(sig_fpga_filtered_demod)
plot(sig_fpga_filtered_demod_iq)

in_bits = 28;
b_bin = floor(b*(2^in_bits - 1)) / (2^in_bits - 1);

sig_matlab_filtered_demod_filtered_bin = filter(b_bin, 1, sig_matlab_filtered_demod_bin);
plot(sig_matlab_filtered_demod_filtered_bin)

phase = rad2deg(atan(mean(sig_fpga_filtered_demod_iq)/mean(sig_fpga_filtered_demod)))

%figure;
%freqz(b,1,200)
%figure;
%freqz(b_bin/(2^in_bits - 1),1,200)

%figure;
%plot(sig_demod_filtered)